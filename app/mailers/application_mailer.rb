class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('DEFAULT_FROM', nil)
  layout 'mailer'
end
