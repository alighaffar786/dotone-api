namespace :wl do
  namespace :stats do
    def update_stat_status(_stats, status)
      _stats.each do |_stat|
        print "[Past Due] #{status} #{_stat.id} (Original ID: #{_stat.original_id})..."

        begin
          s = AffiliateStat.cached_find(_stat.id)

          # Make sure to check for Pending status in case
          # of discrepancies
          if s.pending?
            s.process_conversion!(
              skip_expiration_check: true,
              skip_revert_no_campaign: true,
              skip_offer_status: true,
              skip_mca_check: false,
              skip_currency_adjustment: true,
              approval: status,
              trace_custom_agent: 'System - PAST DUE',
              fire_s2s_queue: true,
            )
          end

          puts 'DONE'
        rescue Exception => e
          puts "ERROR: #{e.message}"
        end
      end
    end

    desc 'Trigger save on Affiliate Stats'
    task save: :environment do
      start_at, end_at = RakeWl.ask_date_range
      counts = AffiliateStat.count(conditions: ['recorded_at >= ? and recorded_at <= ?', start_at, end_at])
      puts "Total Stats: #{counts}"
      RakeWl.ask_continue

      batch = 0
      AffiliateStat.between(start_at, end_at, :recorded_at).find_in_batches(batch_size: 1000) do |group|
        batch += 1
        group.each_with_index do |stat, idx|
          print "([Batch #{batch}] #{idx + 1} of #{group.length}) Saving Stat ID: #{stat.id}..."
          puts stat.save
          puts 'DONE!'
        end
      end
    end

    desc 'Refresh forex data on past conversions'
    task :refresh_forex, [:options] => :environment do |_t, args|
      options = args[:options] || {}
      start_at, end_at = RakeWl.ask_date_range(options)
      print 'Date Type: '
      date_type = STDIN.gets.chomp

      time_zone = TimeZone.platform
      counts = AffiliateStat.count(conditions: ["#{date_type} >= ? and #{date_type} <= ?", start_at, end_at])
      puts "Total Stats: #{counts}"

      RakeWl.ask_continue

      batch = 0
      AffiliateStat.between(start_at, end_at, date_type.to_sym, time_zone)
        .find_in_batches(batch_size: 1000) do |group|
        batch += 1
        group.each_with_index do |stat, idx|
          puts "([Batch #{batch}] #{idx + 1} of #{group.length}) Processing Stat ID: #{stat.id}:"
          begin
            print '  Refreshing forex: '
            stat.refresh_forex!(force: true)
            puts 'DONE'
          rescue Exception => e
            puts "FAILED: #{e.message}"
          end

          begin
            print '  Putting to kinesis: '
            stat.mirror_to_redshift
            puts 'DONE'
          rescue Exception => e
            puts "FAILED: #{e.message}"
          end
        end
      end
    end

    desc 'Refresh conversion step snapshot'
    task :refresh_conversion_step_snapshot, [:options] => :environment do |_t, args|
      options = args[:options] || {}
      start_at, end_at = RakeWl.ask_date_range(options)
      print 'Date Type: '
      date_type = STDIN.gets.chomp

      time_zone = TimeZone.platform
      offers = RakeWl.ask_offers(options)
      counts = AffiliateStat.count(
        conditions: [
          "#{date_type} >= ? and #{date_type} <= ? and offer_id IN(?)",
          start_at, end_at, offers.map(&:id)
        ],
      )
      puts "Total Stats: #{counts}"

      RakeWl.ask_continue

      batch = 0
      AffiliateStat.between(start_at, end_at, date_type.to_sym, time_zone)
        .with_offers(offers)
        .find_in_batches(batch_size: 1000) do |group|
        batch += 1
        group.each_with_index do |stat, idx|
          puts "([Batch #{batch}] #{idx + 1} of #{group.length}) Processing Stat ID: #{stat.id}:"
          begin
            print '  Refreshing snapshot: '
            stat.refresh_conversion_step_snapshot!
            puts 'DONE'
          rescue Exception => e
            puts "FAILED: #{e.message}"
          end

          begin
            print '  Putting to kinesis: '
            stat.mirror_to_redshift
            puts 'DONE'
          rescue Exception => e
            puts "FAILED: #{e.message}"
          end
        end
      end
    end

    desc 'Recalculate transactions'
    task :recalculate, [:options] => :environment do |_t, args|
      options = args[:options] || {}
      start_at, end_at = RakeWl.ask_date_range(options)
      time_zone = TimeZone.platform
      counts = AffiliateStat.count(conditions: ['captured_at >= ? and captured_at <= ?', start_at, end_at])
      puts "Total Stats: #{counts}"

      RakeWl.ask_continue

      batch = 0
      AffiliateStat.between(start_at, end_at, :captured_at, time_zone)
        .find_in_batches(batch_size: 1000) do |group|
        batch += 1
        group.each_with_index do |stat, idx|
          puts "([Batch #{batch}] #{idx + 1} of #{group.length}) Recalculate Stat ID: #{stat.id}:"
          begin
            print '  Recalculate: '
            stat.recalculate!
            puts 'DONE'
          rescue Exception => e
            puts "FAILED: #{e.message}"
          end
        end
      end
    end

    desc 'Copy data from MySQL to Kinesis'
    task :put_to_kinesis, [:options] => :environment do |_t, args|
      options = args[:options] || {}
      time_zone = TimeZone.platform
      condition_statements = []
      condition_values = []

      date_type = RakeWl.ask_date_type(options)
      raise 'Date Type is Required.' if date_type.blank?

      force_index_sql = if date_type == 'recorded_at'
        'FORCE INDEX(PRIMARY)'
      elsif date_type == 'captured_at'
        'FORCE INDEX(index_affiliate_stats_on_captured_at)'
      elsif date_type == 'published_at'
        'FORCE INDEX(index_affiliate_stats_on_published_at)'
      elsif date_type == 'converted_at'
        'FORCE INDEX(index_affiliate_stats_on_converted_at)'
      elsif date_type == 'updated_at'
        'FORCE INDEX(index_affiliate_stats_on_updated_at)'
      end

      start_at, end_at = RakeWl.ask_date_range(options.merge(time_zone: time_zone))

      if start_at.present?
        condition_statements << "#{date_type} >= ?"
        condition_values << start_at
      end
      if end_at.present?
        condition_statements << "#{date_type} <= ?"
        condition_values << end_at
      end

      min_id = RakeWl.ask_min_id(options)
      if min_id.present?
        condition_statements << 'id >= ?'
        condition_values << min_id
      end

      offers = RakeWl.ask_offers(options)

      if offers.present?
        offer_ids = offers.compact.map(&:id).join(',')
        condition_statements << "offer_id IN (#{offer_ids})"
      end

      use_batch = RakeWl.ask_for('User Batch (y/n)?')

      batch_size = 100_000

      if use_batch == 'y'
        batch_size = RakeWl.ask_for('Batch size (default: 100,000)?')
        batch_size = batch_size.to_i
      end

      conditions = [condition_statements.join(' AND ')]
      conditions += condition_values

      counts = AffiliateStat.count(conditions: conditions)
      stats = AffiliateStat.where(conditions).from("affiliate_stats #{force_index_sql}")
      puts "Total Stats: #{counts}"
      puts "SQL: #{stats.to_sql}"
      RakeWl.ask_continue

      if use_batch == 'y'
        batch = 0
        stats.find_in_batches(batch_size: batch_size) do |group|
          batch += 1
          group.each_with_index do |stat, idx|
            print "[([Batch #{batch}] #{idx + 1} of #{group.length}) Putting Stat ID: #{stat.id}..."

            DotOne::Utils::Rescuer.no_deadlock do
              puts stat.mirror_to_redshift({ console: true })
            end

            puts 'DONE!'
          end
        end
      else
        data_length = stats.length
        stats.each_with_index do |stat, idx|
          print "[(#{idx + 1} of #{data_length}) Putting Stat ID: #{stat.id}..."
          puts stat.mirror_to_redshift({ console: true })
          puts 'DONE!'
        end
      end
    end

    desc 'Print partition names'
    task print_partition_names: :environment do
      print 'Enter Partition Year: '
      year = STDIN.gets.chomp

      names = []

      1.upto(12) do |month|
        month_string = '%02d' % month
        partitions = [
          2, 4, 6, 8, 10, 12, 14, 16, 18,
          20, 22, 24, 26, 28, 30
        ]

        partitions.each_with_index do |date, subpart|
          next if month == 2 and date > 28

          # Build partition name
          subpart_string = '%02d' % subpart
          partition_name = "p#{year}#{month_string}SUB#{subpart_string}"

          names << partition_name
        end
      end

      puts names.join(',')
    end

    desc 'Generate sql commands for partitions'
    task generate_partition_sql: :environment do
      print 'Enter Partition Type (Add/New/Drop): '
      mode = STDIN.gets.chomp.downcase

      print 'Enter Partition Year: '
      year = STDIN.gets.chomp

      sql = []

      if mode == 'new'
        sql << 'ALTER TABLE affiliate_stats PARTITION BY RANGE ( TO_DAYS(recorded_at) ) ('
      elsif mode == 'add'
        sql << 'ALTER TABLE affiliate_stats ADD PARTITION ('
      elsif mode == 'drop'
        sql << 'ALTER TABLE affiliate_stats DROP PARTITION '
      end

      partition_sql = []

      1.upto(12) do |month|
        month_string = '%02d' % month
        partitions = [
          2, 4, 6, 8, 10, 12, 14, 16, 18,
          20, 22, 24, 26, 28, 30
        ]

        partitions.each_with_index do |date, subpart|
          next if month == 2 and date > 28

          # Build partition name
          subpart_string = '%02d' % subpart
          partition_name = "p#{year}#{month_string}SUB#{subpart_string}"

          # Build timestamp
          year_part = year
          month_part = '%02d' % month
          date_part = '%02d' % date
          timestamp = "#{year_part}-#{month_part}-#{date_part} 00:00:00"

          partition_sql << if mode == 'drop'
            partition_name
          else
            "  PARTITION #{partition_name} VALUES LESS THAN (TO_DAYS('#{timestamp}'))"
          end
        end
      end

      sql << partition_sql.join(",\n")

      sql << ');' if mode != 'drop'

      puts sql.join("\n")
    end

    task import_from_csv: :environment do
      rows_to_insert = []
      CSV.foreach("#{Rails.root}/data/missing-transactions.csv", headers: true) do |row|
        row_to_insert = row.to_hash
        rows_to_insert << row_to_insert
      end
      AffiliateStat.import(rows_to_insert)
    end

    task :restore_using_order_numbers, [:options] => :environment do |_t, _args|
      order_numbers = RakeWl.ask_for('ORDER NUMBERS')
      order_numbers = order_numbers.split(',').map(&:strip)

      orders = Order.where(order_number: order_numbers)

      stat_ids = []
      order_ids = []

      orders.each do |order|
        stat_ids << order.affiliate_stat_id
        order_ids << order.id
      end

      parent_stats = Stat.where(id: stat_ids)
      child_stats = Stat.where(order_id: order_ids)

      all_stats = [parent_stats, child_stats].flatten

      puts "Restoring #{all_stats.length} stats:"

      [parent_stats, child_stats].flatten.each do |stat|
        print "  Stat #{stat.id}..."
        affiliate_stat = stat.to_affiliate_stat
        if affiliate_stat.present?
          affiliate_stat.mirror_to_redshift
          puts 'DONE'

          # Handle any child orders for this stat
          order_ids = affiliate_stat.orders.map(&:id)
          copy_stats = Stat.where(order_id: order_ids)

          copy_stats.each do |copy_stat|
            print "    Copy Stat: #{copy_stat.id}..."
            cs = copy_stat.to_affiliate_stat
            if cs.present?
              cs.mirror_to_redshift
              puts 'DONE'
            else
              puts 'FAILED'
            end
          end
        else
          puts 'FAILED'
        end
      rescue Exception => e
        puts "ERROR: #{e.message}: #{e.backtrace}"
      end
    end

    task stress_test: :environment do
      posts = []
      1.upto(100) do
        posts << ConverlyUtility::Future.new.go do |_args|
          to_return = {}
          start_at = Time.now
          url = 'https://vbtrax.com/track/postback/conversions/8/global?order=42392379120919&order_total=0.30&revenue=0.01&server_subid=c233305d4d35f4acc95a0da2273880e4&step=sale'
          uri = URI(url)
          res = Net::HTTP.get_response(uri)
          to_return[:res_body] = res.body
          end_at = Time.now
          to_return[:duration] = (end_at - start_at)
          to_return
        end
      end

      results = []
      posts.each do |p|
        results << p.value!
      end

      puts results
    end
  end
end
