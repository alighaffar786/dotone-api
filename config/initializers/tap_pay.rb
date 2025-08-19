TapPay.setup do |config|
  config.mode = Rails.env.production? ? :production : :sandbox # sandbox or production
  config.partner_key = ENV.fetch('TAP_PAY_PARTNER_KEY', nil) # optional
end
