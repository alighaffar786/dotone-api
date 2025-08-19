namespace :cdn do
  task restart: :environment do
    raise 'Not the correct server type.' unless SERVER_TYPE == 'SUPPORT'

    system 'sudo service process_cdn restart'
  end

  task stop: :environment do
    system 'sudo service process_cdn stop'
  end

  task compress: :environment do
    require 'uglifier'

    minimized_dir = Rails.root.join('public', 'javascripts')
    paths = Dir.glob(Rails.root.join('lib', 'javascripts', '*.uncompressed.js'))
    puts "paths: #{paths}"

    paths.each do |path|
      minimized = Uglifier.compile(File.read(path))
      original_file_name = File.basename(path)
      file_name = original_file_name.sub('.uncompressed', '')

      FileUtils.mkdir_p(minimized_dir)
      minimized_path = minimized_dir.join(file_name)

      puts "writing #{minimized_path}"
      File.write(minimized_path, minimized)

      if Rails.env.development?
        uncompressed = minimized_dir.join(original_file_name)
        puts "symlink created: #{uncompressed}"
        FileUtils.ln_s(path, uncompressed)
      end
    end
  end

  task process: :environment do
    worker_size = ENV.fetch('CDN_WORKER', 10).to_i
    bucket = Aws::S3::Bucket.new(CDN_LOG_BUCKET_NAME)

    loop do
      if DotOne::SidekiqHelper.count_all('cdn', 'Cdn::ProcessJob') > worker_size
        sleep 20
        next
      end
      ##
      # For each object in the bucket:
      folder_name = 'pending-logs'

      bucket.objects(prefix: folder_name).each do |file|
        source_file = file.key.gsub("#{folder_name}/", '')

        next if source_file.blank?
        next if DotOne::SidekiqHelper.exists_any?('cdn', 'Cdn::ProcessJob', file.key)
        break if DotOne::SidekiqHelper.count_all('cdn', 'Cdn::ProcessJob') > worker_size

        Cdn::ProcessJob.perform_later(file.key)
        sleep 1
      end
    rescue Exception => e
      Sentry.capture_exception(e)
      CDN_LOGGER.error("[#{Time.now}]: #{e.message} #{e.backtrace}")

      break
    end
  end
end
