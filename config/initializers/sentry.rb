require 'sentry-ruby'
require 'sentry-rails'

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN', nil)

  # this gem also provides a new breadcrumb logger that accepts instrumentations from ActiveSupport
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set value between 0.0 and 1.0
  # 1.0 will capture 100% of transactions for performance monitoring.
  config.traces_sample_rate = ENV.fetch('SENTRY_TRACE_SAMPLE_RATE', 0.5).to_f

  # report exceptions rescued by ActionDispatch::ShowExceptions or ActionDispatch::DebugExceptions middlewares
  # the default value is true
  config.rails.report_rescued_exceptions = true

  # Don't care about development or test
  config.enabled_environments = ['staging,', 'production']
  config.environment = ENV.fetch('SERVER_NAME', 'staging')
end
