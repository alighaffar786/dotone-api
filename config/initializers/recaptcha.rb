Recaptcha.configure do |config|
  config.secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY')
  config.skip_verify_env = ['development', 'test']
end
