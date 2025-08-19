# frozen_string_literal: true

class Archive::BackupLogJob < MaintenanceJob
  BUCKET_NAME = 'support-server-log-archive'
  CHUNK_SIZE = 10 * 1024 * 1024 # 10MB

  def perform(logger_index = nil)
    if logger_index.nil?
      loggers.each_with_index do |logger, index|
        upload(logger)
      rescue StandardError
        Archive::BackupLogJob.perform_later(index)
        next
      end
    else
      upload(loggers[logger_index])
    end
  end

  private

  def s3
    @s3 ||= Aws::S3::Client.new
  end

  def date
    @date ||= Time.current.strftime('%Y-%m-%d')
  end

  def loggers
    [
      STAT_SYNC_LOGGER,
      STAT_SYNC_ORDER_NUMBER_LOGGER,
      STAT_SYNC_CLICK_ID_LOGGER,
      STAT_IMPORT_LOGGER,
      STAT_DUPLICATE_CLEANUP_LOGGER,
      PAST_DUE_LOGGER,
      STATS_ARCHIVER_LOGGER,
      NETWORK_RAKE_LOGGER,
      ORDER_API_PULL_LOGGER,
      ORDER_CLEANUP_LOGGER,
      PRODUCT_IMPORT_LOGGER,
      CDN_LOGGER,
      KINESIS_STAT_LOGGER,
      ORDER_FINALIZER_LOGGER,
      KINESIS_LOGGER,
      KINESIS_STATE_LOGGER,
      MISSING_ORDER_LOGGER,
      DELAYED_CONVERSION_LOGGER,
      KINESIS_CONVERSION_LOGGER,
    ]
  end

  def upload(logger)
    log_path = logger.instance_variable_get(:@logdev).filename # result will be like /app/log/stat_sync.log
    filename = File.basename(log_path, '.*') # result will be like stat_sync

    Dir.glob(Rails.root.join('log', "#{filename}.*")).each do |log_file|
      next if !File.exist?(log_file) || File.zero?(log_file)

      object_key = "#{Rails.env}/#{filename}/#{date}/#{File.basename(log_file)}"

      resp = s3.create_multipart_upload(bucket: BUCKET_NAME, key: object_key)
      upload_id = resp.upload_id

      part_number = 1
      parts = []

      begin
        File.open(log_file, 'rb') do |file|
          while chunk = file.read(CHUNK_SIZE)
            part = s3.upload_part(
              bucket: BUCKET_NAME,
              key: object_key,
              upload_id: upload_id,
              part_number: part_number,
              body: chunk
            )
            parts << { part_number: part_number, etag: part.etag }
            part_number += 1
          end
        end

        s3.complete_multipart_upload(
          bucket: BUCKET_NAME,
          key: object_key,
          upload_id: upload_id,
          multipart_upload: { parts: parts }
        )
      rescue Exception => e
        s3.abort_multipart_upload(bucket: BUCKET_NAME, key: object_key, upload_id: upload_id)
        raise e
      end

      current_filename = File.basename(log_file)
      original_filename = "#{filename}.log"
      if current_filename == original_filename
        File.open(log_file, 'w') {}
      else
        File.delete(log_file)
      end
    end
  end
end
