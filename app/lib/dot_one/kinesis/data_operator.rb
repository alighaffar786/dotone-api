require 'logger'

class DotOne::Kinesis::DataOperator
  def self.kinesis_to_partition_tables(stat_hash)
    start_time = Time.now

    stat_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_PARTITION_TABLES]

      next if data_array.blank?

      delete_ids = []
      captured_at_data = {}
      published_at_data = {}
      converted_at_data = {}

      delete_statements = {}
      insert_statements = {}

      data_array.each do |data_hash|
        current_stat = data_hash[:data]

        column_names = current_stat.keys

        next if current_stat['id'].blank?

        # Skip any stat that don't matter
        # for this case
        next if current_stat['recorded_at'].blank?
        next if current_stat['recorded_at'].blank? && current_stat['captured_at'].blank? && current_stat['published_at'].blank? && current_stat['converted_at'].blank?

        # Record ids to be deleted
        delete_ids << current_stat['id'] unless delete_ids.include?(current_stat['id'])

        # Build the sql string fragment for each stat
        values = []
        question_marks = []
        column_names.each do |col|
          question_marks << '?'
          values << if current_stat[col].present?
            if AffiliateStat.columns_hash[col] && AffiliateStat.columns_hash[col].type == :datetime
              time = Time.parse(current_stat[col])
              time = nil if time.present? && time > 5.years.from_now
              time
            else
              current_stat[col]
            end
          end
        end
        sql_fragment = AffiliateStat.sanitize_sql(["(#{question_marks.join(', ')})", *values])

        # Categorize into each appropriate partitions
        captured_at_data[current_stat['id']] = sql_fragment if current_stat['captured_at'].present?
        published_at_data[current_stat['id']] = sql_fragment if current_stat['published_at'].present?
        converted_at_data[current_stat['id']] = sql_fragment if current_stat['converted_at'].present?
      end

      # Make sure delete and insert operation is in smaller batches
      # to prevent performance hit to database
      delete_ids_batch = delete_ids.each_slice(500).to_a

      delete_statements['AffiliateStatCapturedAt'] = []
      delete_statements['AffiliateStatPublishedAt'] = []
      delete_statements['AffiliateStatConvertedAt'] = []

      delete_ids_batch.each do |ids_to_delete|
        sql = <<-SQL.squish
          DELETE FROM affiliate_stat_captured_ats WHERE id IN ('#{ids_to_delete.join("','")}')
        SQL

        delete_statements['AffiliateStatCapturedAt'] << { sql: sql, ids: ids_to_delete }

        sql = <<-SQL.squish
          DELETE FROM affiliate_stat_published_ats WHERE id IN ('#{ids_to_delete.join("','")}')
        SQL

        delete_statements['AffiliateStatPublishedAt'] << { sql: sql, ids: ids_to_delete }

        sql = <<-SQL.squish
          DELETE FROM affiliate_stat_converted_ats WHERE id IN ('#{ids_to_delete.join("','")}')
        SQL

        delete_statements['AffiliateStatConvertedAt'] << { sql: sql, ids: ids_to_delete }
      end

      insert_statements['AffiliateStatCapturedAt'] = []
      insert_statements['AffiliateStatPublishedAt'] = []
      insert_statements['AffiliateStatConvertedAt'] = []

      if captured_at_data.present?
        captured_at_data.values.each_slice(500) do |value_strings|
          value_string = value_strings.join(', ')
          insert_statements['AffiliateStatCapturedAt'] << <<-SQL.squish
            INSERT INTO affiliate_stat_captured_ats(#{AffiliateStat.column_names.join(',')})
            VALUES #{value_string}
          SQL
        end
      end

      if published_at_data.present?
        published_at_data.values.each_slice(500) do |value_strings|
          value_string = value_strings.join(', ')
          insert_statements['AffiliateStatPublishedAt'] << <<-SQL.squish
            INSERT INTO affiliate_stat_published_ats(#{AffiliateStat.column_names.join(',')})
            VALUES #{value_string}
          SQL
        end
      end

      if converted_at_data.present?
        converted_at_data.values.each_slice(500) do |value_strings|
          value_string = value_strings.join(', ')
          insert_statements['AffiliateStatConvertedAt'] << <<-SQL.squish
            INSERT INTO affiliate_stat_converted_ats(#{AffiliateStat.column_names.join(',')})
            VALUES #{value_string}
          SQL
        end
      end

      KINESIS_STAT_LOGGER.warn("[TO PARTITION TABLES] Processing #{data_array.length} records")

      ActiveRecord::Base.transaction do
        delete_statements.each_pair do |klass_string, sql_array|
          sql_array.each do |sql_spec|
            KINESIS_STAT_LOGGER.warn("  [TO PARTITION TABLES] DELETING ID: #{sql_spec[:ids]}")
            klass_string.constantize.connection.execute(sql_spec[:sql])
          end
        end

        insert_statements.each_pair do |klass_string, sql_array|
          KINESIS_STAT_LOGGER.warn("  [TO PARTITION TABLES] INSERTING #{klass_string} #{sql_array.length} records")
          KINESIS_STAT_LOGGER.warn("    SQL: #{sql_array.join("\r\n")}") if sql_array.length > 0

          sql_array.each do |sql|
            DotOne::Utils::Rescuer.no_deadlock do
              klass_string.constantize.connection.execute(sql)
            end
          end
        end
      end

      duration = ((Time.now - start_time) / 1.second).round
      KINESIS_STAT_LOGGER.warn("[TO PARTITION TABLES] Processed #{data_array.length} records in #{duration} seconds")
    end
  end

  def self.kinesis_to_redshift(stat_hash)
    start_time = Time.now
    columns = AffiliateStat.columns.map(&:name)

    stat_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_REDSHIFT]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn("[TO REDSHIFT] PROCESSING Timestamp: #{data_array.last[:data]['updated_at']}")

      inserts = {}
      deletes = {}

      data_array.each do |data_hash|
        value = []

        current_stat = data_hash[:data]

        # Bug fixing on recorded_at is blank.
        # There was an error which result in corrupt data
        # causing recorded_at to be blank.
        recorded_at_str = current_stat['recorded_at']
        next if recorded_at_str.blank?

        recorded_date = Time.parse(recorded_at_str).to_date
        next if recorded_date < Stat.date_limit

        columns.each do |col|
          value << if ['manual_notes'].include?(col.to_s)
            ''
          elsif current_stat[col].to_s =~ /CASE WHEN/
            nil
          elsif current_stat[col].to_s.match(/\0/)
            current_stat[col].to_s.gsub(/\0/, '')
          else
            current_stat[col]
          end
        end

        question_marks = ['?'].cycle(value.length).to_a.join(',')
        deletes[current_stat['id']] = current_stat['id']
        inserts[current_stat['id']] = Stat.sanitize_sql(["(#{question_marks})"] + value)
      end

      delete_sql = ''
      insert_sql = ''

      begin
        if deletes.present?
          ids = deletes.values.join("','")
          delete_sql = "DELETE FROM stats WHERE id IN ('#{ids}')"
          KINESIS_STAT_LOGGER.warn("  [TO REDSHIFT] DELETING #{deletes.values.length} records")
          Stat.exec_sql(delete_sql)
        end

        if inserts.present?
          insert_sql = ["INSERT INTO stats (#{columns.join(',')}) VALUES"]
          insert_sql << inserts.values.join(', ')
          KINESIS_STAT_LOGGER.warn("  [TO REDSHIFT] INSERTING #{inserts.values.length} records")
          insert_sql = insert_sql.join('')
          Stat.exec_sql(insert_sql)
        end

        duration = ((Time.now - start_time) / 1.second).round
        KINESIS_STAT_LOGGER.warn("  [TO REDSHIFT] Processed #{data_array.length} records in #{duration} seconds")
      end
    end
  end

  def self.kinesis_to_save_clicks(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_SAVE_CLICK]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[SAVE CLICK] Processing #{data_array.length} records"

      value_array = []

      data_array.each do |data_hash|
        current_stat = data_hash[:data]
        column_names = current_stat.keys
        current_stat['subid_1'] = nil if current_stat['id'] =='fe4e582793496c2d1e54636eb70bbfa0'

        column_names.each do |col|
          begin
            column_hash = AffiliateStat.columns_hash[col]
            column_type = column_hash.type
            column_limit = column_hash.limit

            if current_stat[col].present? && column_type == :datetime
              current_stat[col] = Time.parse(current_stat[col]).to_s(:db)
            elsif current_stat[col].present? && column_type == :string && current_stat[col].is_a?(String)
              current_stat[col] = current_stat[col].byteslice(0, column_limit)
              current_stat[col] = DotOne::Utils.to_utf8(current_stat[col])
              current_stat[col] = DotOne::Utils.cleanup_emoji(current_stat[col]).presence
            end
          rescue ArgumentError
            current_stat[col] = DotOne::Utils.to_utf8(current_stat[col].to_s.byteslice(0, 255)).presence
            retry
          end
        rescue Exception => e
          Sentry.capture_exception(e)
          error_message = e.message
          backtrace = e.backtrace.join("\r\n")
          KINESIS_LOGGER.error "[SAVE CLICK] Skip column sanitazion #{col}: #{current_stat}. #{error_message}"
          KINESIS_LOGGER.error backtrace
          raise e
        end

        value_array << current_stat
      end

      KINESIS_STAT_LOGGER.warn "    For ID: #{value_array.map { |value| value['id'] }}"
      AffiliateStat.bulk_save_clicks(value_array)
    end
  end

  def self.kinesis_to_save_missing_clicks(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_SAVE_CLICK]

      next if data_array.blank?

      KINESIS_MISSING_STAT_LOGGER.warn "[SAVE MISSING CLICK] Processing #{data_array.length} records"

      value_array = []

      data_array.each do |data_hash|
        current_stat = data_hash[:data]
        column_names = current_stat.keys

        column_names.each do |col|
          if current_stat[col].present? && (AffiliateStat.columns_hash[col] && AffiliateStat.columns_hash[col].type == :datetime)
            current_stat[col] = Time.parse(current_stat[col]).to_s(:db)
          end
        rescue Exception => e
          Sentry.capture_exception(e)
          error_message = e.message
          backtrace = e.backtrace.join("\r\n")
          KINESIS_MISSING_STAT_LOGGER.error "[SAVE CLICK] Skip column sanitazion #{col}: #{current_stat}. #{error_message}"
          KINESIS_MISSING_STAT_LOGGER.error backtrace
          raise e
        end

        value_array << current_stat
      end

      next if value_array.blank?

      ids = value_array.map { |value| value['id'] }
      current_ids = AffiliateStat.where(id: ids).pluck(:id)

      puts "current"
      puts ids.inspect
      puts "found"
      puts current_ids.inspect
      diff = ids - current_ids

      new_values = []

      if diff.present?
        new_values = value_array.select { |value| diff.include?(value['id']) }
        puts "diff"
        puts diff.inspect
      else
        puts "no diff"
      end

      new_values.each do |value|
        Sentry.capture_exception(Exception.new("New click found #{value}"))
        AffiliateStat.save_click!(value)
      end

      KINESIS_MISSING_STAT_LOGGER.warn "    For ID: #{value_array.map { |value| value['id'] }}"
    end
  end

  def self.kinesis_to_process_conversions(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_PROCESS_CONVERSION]

      next if data_array.blank?

      KINESIS_CONVERSION_LOGGER.warn "[PROCESS CONVERSION] Processing #{data_array.length} records"

      data_array.each do |data_hash|
        data = data_hash[:data]
        kinesis_options = data_hash[:args] && data_hash[:args][0]
        kinesis_options = kinesis_options.with_indifferent_access

        # TODO: Remove this once transition is done
        if kinesis_options[:options].blank?
          kinesis_options[:options] = kinesis_options
          kinesis_options[:params] = kinesis_options
          kinesis_options[:request_string] = nil
        end

        # TODO: Remove data["id"] once transition is done
        lookup_id = data['id'] || kinesis_options['stat_id']

        KINESIS_CONVERSION_LOGGER.warn "  [PROCESS CONVERSION] To Process - Stat ID: #{lookup_id} Captured At: #{kinesis_options['options']['captured_at']}"
        KINESIS_CONVERSION_LOGGER.warn "  [PROCESS CONVERSION] To Process - Stat ID: #{lookup_id} #{kinesis_options}"

        affiliate_stat = AffiliateStat.find_by_id(lookup_id)
        conversion_options = kinesis_options[:options].merge(kinesis_options[:params])

        if lookup_id.present? && affiliate_stat.blank? || affiliate_stat.present? && affiliate_stat.conversion_steps.blank?
          KINESIS_CONVERSION_LOGGER.warn "  [PROCESS CONVERSION] NOT FOUND - Stat ID: #{lookup_id}"
          conversion_options[:captured_at] ||= Time.now.to_s(:db)

          AffiliateStats::ConversionJob.perform_later(lookup_id, conversion_options, nil, kinesis_options[:request_string])
        elsif affiliate_stat.present?
          result = affiliate_stat.process_conversion!(conversion_options)

          KINESIS_CONVERSION_LOGGER.warn "  [PROCESS CONVERSION] RESULT - Stat ID: #{lookup_id} #{result}"
        end

        if conversion_options['pixel_installed'].present? && affiliate_stat&.cached_offer.present?
          affiliate_stat.cached_offer.record_pixel_installed!(conversion_options['pixel_installed'])
        end
      end
    end
  end

  def self.kinesis_to_attach_sibling(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_ATTACH_SIBLING]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[ATTACH SIBLING] Processing #{data_array.length} records"
      data_array.each do |data_hash|
        data = data_hash[:data]
        options = data_hash[:args]

        KINESIS_STAT_LOGGER.warn "Attach sibling for DATA: #{data}. OPTIONS: #{options}"

        DotOne::AffiliateStats::SiblingAttacher.attach(*options)
      end
    end
  end

  def self.kinesis_to_delayed_touch(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_DELAYED_TOUCH]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[DELAYED TOUCH] Processing #{data_array.length} records"

      ids = data_array.map { |data_hash| data_hash[:data]['id'] }.uniq
      ids.each_slice(500) do |group_ids|
        KINESIS_STAT_LOGGER.warn "    [DELAYED TOUCH] For ID: #{group_ids}"

        AffiliateStat.where(id: group_ids).update_all(updated_at: Time.now)
      end
    end
  end

  def self.kinesis_to_partition_delayed_touch(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_PARTITION_DELAYED_TOUCH]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[PARTITION DELAYED TOUCH] Processing #{data_array.length} records"

      ids = data_array.map { |data_hash| data_hash[:data]['id'] }.uniq
      ids.each_slice(500) do |group_ids|
        KINESIS_STAT_LOGGER.warn "    [PARTITION DELAYED TOUCH] For ID: #{group_ids}"

        AffiliateStat::PARTITIONS.each do |klass|
          klass.where(id: group_ids).update_all(updated_at: Time.now)
        end
      end
    end
  end

  def self.kinesis_to_save_tracking_domain_stat(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_SAVE_TRACKING_DOMAIN_STAT]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[SAVE TRACKING DOMAIN STAT] Processing #{data_array.length} records"

      value_array = data_array.map { |x| x[:args] }.flatten

      KINESIS_STAT_LOGGER.warn "[DOMAIN STAT] #{value_array}"

      AlternativeDomainStat.bulk_save_clicks(value_array)
    end
  end

  def self.kinesis_to_save_postback(kinesis_hash)
    kinesis_hash.each_pair do |wl_id, task_hash|
      data_array = task_hash[DotOne::Kinesis::TASK_SAVE_POSTBACK]

      next if data_array.blank?

      KINESIS_STAT_LOGGER.warn "[SAVE POSTBACK] Processing #{data_array.length} records"

      value_array = data_array.map { |x| x[:args] }.flatten

      KINESIS_STAT_LOGGER.warn "[SAVE POSTBACK] #{value_array}"

      value_array_to_save = value_array.map do |value|
        value = value.slice(*Postback.column_names)
        value['ip_address'] = value['ip_address']
        value
      end

      Postback.import(value_array_to_save, validate_uniqueness: true)

      value_array.each do |value|
        raw_request = value['raw_request']
        request_origin = value['request_origin']

        next if raw_request.blank? || request_origin.blank?
        next unless raw_request.start_with?('https://t.adotone.com/track/imp/mkt_site/8')

        begin
          uri = URI.parse(raw_request)
          mkt_site_id = uri.path.split('/')[5]
          mkt_site = MktSite.cached_find(mkt_site_id)

          next if mkt_site.blank? || mkt_site.verified?

          mkt_site.verify_domain(request_origin)

        rescue URI::InvalidURIError
        end
      end
    end
  end
end
