# frozen_string_literal: true

class Cdn::ProcessJob < ApplicationJob
  queue_as :cdn

  def perform(key)
    bucket = Aws::S3::Bucket.new(CDN_LOG_BUCKET_NAME)
    file = bucket.object(key)

    return unless file.exists?

    current_batch = key.gsub('pending-logs/', '')
    CDN_LOGGER.info("[#{Time.now}] Process s3 File: #{current_batch}")

    # CDN Processors are listed here
    creative_impression_processor = DotOne::CdnProcessor::Creative::Impression::Processor.new
    site_info_view_stat_processor = DotOne::CdnProcessor::SiteInfo::UniqueView::Processor.new
    offer_detail_view_processor = DotOne::CdnProcessor::Offer::DetailView::Processor.new

    CDN_LOGGER.info("  [#{Time.now}] Cleaning up any corrupted imports...")

    # Rollback any impression caused by process breaking
    # down in the middle of insert operation
    creative_impression_processor.rollback(current_batch)
    site_info_view_stat_processor.rollback(current_batch)
    offer_detail_view_processor.rollback(current_batch)

    # Download the gzip file
    gzip_file = "#{Rails.root}/tmp/#{current_batch}"
    download = URI.open(file.presigned_url(:get))
    IO.copy_stream(download, gzip_file)

    # Open/extract the gzip file
    uncompressed_file = "#{Rails.root}/tmp/#{current_batch}-uncompressed"
    IO.copy_stream(Zlib::GzipReader.open(gzip_file), uncompressed_file)

    # Process the file for processing
    current_file = File.open(uncompressed_file)
    1.upto(2) { current_file.readline }

    CSV.parse(current_file, col_sep: "\t").each do |row|
      # Process Creative Impression Record
      creative_impression_processor.add_row(row, current_batch)

      # Process Site Info Unique View
      site_info_view_stat_processor.add_row(row)

      # Process Offer Detail View
      offer_detail_view_processor.add_row(row)
    end

    # Save Everything
    creative_impression_processor.save(current_batch)
    site_info_view_stat_processor.save(current_batch)
    offer_detail_view_processor.save(current_batch)

    # Delete local files
    [gzip_file, uncompressed_file].each do |file|
      File.delete(file) rescue nil
    end

    # Copy s3 file
    source_bucket_name = CDN_LOG_BUCKET_NAME
    target_bucket_name = CDN_LOG_BUCKET_NAME
    source_key = file.key
    target_key = "processed-logs/#{current_batch}"

    begin
      s3 = Aws::S3::Client.new
      s3.copy_object(
        bucket: target_bucket_name,
        copy_source: [source_bucket_name, source_key].join('/'),
        key: target_key
      )
    rescue StandardError => e
      CDN_LOGGER.error("[#{Time.now}] Caught exception copying object #{source_key} from bucket #{source_bucket_name} to bucket #{target_bucket_name} as #{target_key}:")
      CDN_LOGGER.error(e.message)
    end

    # Delete s3 files
    file.delete
  end
end
