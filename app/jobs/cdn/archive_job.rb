# frozen_string_literal: true

class Cdn::ArchiveJob < ApplicationJob
  queue_as :cdn

  def perform
    bucket_name = CDN_LOG_BUCKET_NAME

    bucket = Aws::S3::Bucket.new(bucket_name)

    folder_name = 'processed-logs'
    latest_stamp_to_archive = 30.days.ago.to_date

    bucket.objects(prefix: folder_name).each do |file|
      file_name = file.key
      print "Processing File: #{bucket_name}/#{file_name}: "
      file_to_process = file_name.gsub("#{folder_name}/", '')
      datestamp_from_name = Date.parse(file_to_process.split('.')[1]) rescue nil

      if datestamp_from_name.blank? || datestamp_from_name > latest_stamp_to_archive
        puts 'SKIPPED'
        next
      end

      target_key = ['processed-logs.']
      target_key << "#{datestamp_from_name.strftime('%Y-%m')}/"
      target_key << 'processed-logs.'
      target_key << "#{datestamp_from_name.strftime('%Y-%m-%d')}/"
      target_key << file_to_process
      target_key = target_key.join

      begin
        s3 = Aws::S3::Client.new
        s3.copy_object(
          bucket: bucket_name,
          copy_source: [bucket_name, file_name].join('/'), key: target_key
        )
        file.delete
        puts " MOVED to #{bucket_name}/#{target_key}"
      rescue StandardError => e
        puts "[#{Time.now}] Caught exception copying object #{file_to_process} target key #{target_key}"
        puts e.message
      end
    end
  end
end
