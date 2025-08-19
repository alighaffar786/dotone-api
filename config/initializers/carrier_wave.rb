CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false

    # use different dirs when testing
    CarrierWave::Uploader::Base.descendants.each do |klass|
      next if klass.anonymous?

      klass.class_eval do
        def cache_dir
          "#{Rails.root}/spec/support/tmp"
        end

        def store_dir
          "#{Rails.root}/spec/support/tmp"
        end
      end
    end
  else
    # used for FOG
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY'),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_KEY'),
      region: 'us-east-1',  # optional, defaults to 'us-east-1'
    }
    config.fog_directory = ENV.fetch('AWS_S3_PUBLIC_BUCKET')
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000', :multipart_chunk_size => 104_857_600 }

    config.asset_host = "https://#{ENV.fetch('CDN_HOST')}"
  end
end
