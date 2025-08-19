# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Sidekiq.configure_server do |config|
    config.on(:startup) do
      schedule_file = 'config/sidekiq_schedule.yml'
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
    end

    config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', nil).to_s }

    config.client_middleware do |chain|
      chain.add DotOne::Middleware::SidekiqClient
    end

    config.server_middleware do |chain|
      chain.add DotOne::Middleware::SidekiqServer
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', nil).to_s }

    config.client_middleware do |chain|
      chain.add DotOne::Middleware::SidekiqClient
    end
  end
end
