require 'open-uri'

namespace :wl do
  namespace :affiliates do
    task save: :environment do
      Affiliate.all.each do |affiliate|
        print "Save Affiliate ID: #{affiliate.id_with_name}..."
        puts affiliate.save
      end
      puts 'DONE!'
    end

    task touch: :environment do
      Affiliate.all.each do |affiliate|
        print "Touch Affiliate ID: #{affiliate.id_with_name}..."
        puts affiliate.touch
      end
      puts 'DONE!'
    end

    # Task to force each affiliates to re-accept the
    # terms and conditions before continuing access to
    # the pub UI
    task reset_terms_acceptance: :environment do
      sql = <<-EOS
        UPDATE affiliate_applications
        SET accept_terms = NULL, age_confirmed = NULL,
          accept_terms_at = NULL, age_confirmed_at = NULL
      EOS
      Affiliate.connection.execute(sql)
    end

    task :reset_columns, [:options] => :environment do |_t, _args|
      Affiliate.all.each do |affiliate|
        print "Resetting columns for affiliate: #{affiliate.id_with_name}..."
        current_columns = affiliate.system_flag(:column_setup)
        if current_columns.present?
          affiliate.system_flag(:column_setup, {})
          puts 'DONE'
        else
          puts 'SKIPPED'
        end
      end
    end

    task update_login_count: :environment do
      affiliates = Affiliate.all
      print "total affiliates: #{affiliates.count}"
      affiliates.each do |affiliate|
        affiliate.login_count = Trace.where('agent_id = ? and verb = ? and created_at >= ?', affiliate.id.to_s, 'logins', 30.days.ago).count
        affiliate.save
        puts "affiliate #{affiliate.id} login count is #{affiliate.login_count}"
      end
    end

    ##
    # Task to import existing or new hash key value pair
    # for affiliate.
    # Remote URL should have the following CSV column header:
    # affiliate_id, hash_key, hash_value
    # If affiliate is not found, row will be skipped.
    # If hash key is not found, one will be created automatically.
    # Put the CSV file remotely that can be accessible via a URL.
    task assign_hash: :environment do
      print 'Remote file URL to import: '
      remote_url = STDIN.gets.chomp
      CSV.new(open(remote_url), headers: :first_row, header_converters: :symbol).each do |row|
        print "Assigning Data #{row}"
        affiliate = Affiliate.find(row[:affiliate_id]) rescue nil
        if affiliate.blank?
          puts ' Affiliate Not Found'
          next
        end
        affiliate.flag(row[:hash_key], row[:hash_value])
        puts 'DONE'
      end
    end

    task add_ad_link_activated_at: :environment do
      start_at, end_at = RakeWl.ask_date_range

      stats = Stat
        .select('affiliate_id, MIN(recorded_at) as min_recorded_at')
        .clicks
        .for_ad_links
        .between(start_at, end_at, :recorded_at, TimeZone.platform)
        .group(:affiliate_id)
        .index_by(&:affiliate_id)

      affiliates = Affiliate.where(id: stats.keys, ad_link_activated_at: nil)
      affiliates.find_each(batch_size: 250) do |affiliate|
        affiliate.update_attribute(:ad_link_activated_at, stats[affiliate.id].min_recorded_at)
      end
    end

    task cleanup_avatar: :environment do
      ids = []

      Image.avatar.find_each do |image|
        begin
          URI.open(image.cdn_url)
        rescue OpenURI::HTTPError
          ids << image.id
        end
      end

      puts ids.inspect
    end

    task cleanup_ad_link: :environment do
      Affiliate.suspended.where.not(ad_link_file: nil).find_each do |affiliate|
        puts "cleanup adlink affiliate id: #{affiliate.id}"
        affiliate.remove_ad_link_file!
        affiliate.ad_link_terms_accepted_at = nil
        affiliate.ad_link_activated_at = nil
        affiliate.ad_link_installed_at = nil
        affiliate.save
      end
    end
  end
end
