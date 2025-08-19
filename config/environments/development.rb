Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  config.hosts.clear

  # Show full error reports.
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = true

  config.active_record.cache_versioning = false

  # config.cache_store = :file_store, "#{Rails.root.to_s}/tmp/cache"

  config.cache_store = :redis_store, ENV.fetch('CACHE_REDIS_URL', nil), {
    namespace: Rails.env,

    # Make sure to double check aws parameters
    # when changing this value
    value_max_bytes: 1024 * 1024 * 128,
  }, {
    expires_in: 7.days,
  }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # config.action_mailer.default_url_options = { host: ENV["HOST"] || "localhost:3000" }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: "smtp.gmail.com",
  #   port: 587,
  #   user_name: ENV["DEV_SMTP_EMAIL_ADDRESS"],
  #   password: ENV["DEV_SMTP_EMAIL_PASSWORD"],
  #   authentication: :plain,
  #   enable_starttls_auto: true,
  #   domain: "gmail.com",
  # }

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true
  config.active_record.belongs_to_required_by_default = false

  config.action_cable.allowed_request_origins = [
    [ENV.fetch('UI_HOST_PROTOCOL', nil), ENV.fetch('ADVERTISER_UI_HOST', nil)].join,
    [ENV.fetch('UI_HOST_PROTOCOL', nil), ENV.fetch('AFFILIATE_UI_HOST', nil)].join,
    [ENV.fetch('UI_HOST_PROTOCOL', nil), ENV.fetch('ADMIN_UI_HOST', nil)].join,
  ]

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.after_initialize do
    Bullet.enable = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.bullet_logger = true
  end
end
