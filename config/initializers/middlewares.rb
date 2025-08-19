Rails.application.configure do
  config.middleware.use ::DotOne::Middleware::BotBlocker
end
