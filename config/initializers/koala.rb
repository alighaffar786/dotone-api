Koala.configure do |config|
  config.app_id = ENV.fetch('FACEBOOK_APP_ID', nil)
  config.app_secret = ENV.fetch('FACEBOOK_APP_SECRET', nil)
  config.api_version = 'v23.0'
end
