class DotOne::Services::S3RedshiftConnector
  def self.rollback_impressions(id_prefix)
    records = Stat.where("id LIKE '#{id_prefix}%'")
    return unless records.length > 0

    CDN_LOGGER.info("DELETING #{records.length} impressions")
    delete_sql = "DELETE FROM stats where id LIKE '#{id_prefix}%'"
    Stat.connection.execute(delete_sql)
  end

  def self.s3_to_redshift(records)
    return if records.blank?

    columns = [
      'id', 'recorded_at', 'offer_id', 'offer_variant_id',
      'affiliate_id', 'affiliate_offer_id',
      'network_id', 'image_creative_id',
      'http_user_agent', 'http_referer',
      'ip_address', 'impression', 'ad_slot_id',
      'text_creative_id'
    ]

    question_marks = ['?'].cycle(columns.length).to_a.join(',')

    CDN_LOGGER.info("INSERTING #{records.length} impressions")

    # Split the record collection to be 500 max each to
    # make sure it does not throw data too large error
    # on Redshift.
    records = records.each_slice(500).to_a
    records.each_with_index do |group, index|
      CDN_LOGGER.info("INSERTING BATCH #{index + 1} of #{records.length}: #{group.length} records")

      insert_sql = ["INSERT INTO stats (#{columns.join(',')}) VALUES"]
      values_sql = []

      group.each do |record|
        values = columns.each do |attribute|
          record.send(attribute)
        end

        values_sql << Stat.sanitize_sql(["(#{question_marks})"] + values)
      end

      insert_sql << values_sql.join(',')
      insert_sql = insert_sql.join('')
      # CDN_LOGGER.info("[S3RedshiftConnector#s3_to_redshift]: #{insert_sql}")
      Stat.connection.execute(insert_sql) rescue nil
    rescue Exception => e
      Sentry.capture_exception(e)
      puts "[S3RedshiftConnector#s3_to_redshift]: #{e.message} #{e.backtrace}"
      CDN_LOGGER.error("[S3RedshiftConnector#s3_to_redshift]: #{e.message} #{e.backtrace}")
      next
    end
  end
end
