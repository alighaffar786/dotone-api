# frozen_string_literal: true

require 'money'
require 'money_oxr/bank'
require 'monetize'
require 'net/http'

# Convert prices to different currencies
Money.default_bank = MoneyOXR::Bank.new(
  app_id: ENV.fetch('OXR_APP_ID', nil),
  cache_path: 'config/oxr.json',
  max_age: 172800 # 2 days in seconds
)

# override gem default method due to unable to read data from api
MoneyOXR::RatesStore.class_eval do
  def get_json_from_api
    Net::HTTP.get(URI(api_uri))
  rescue StandardError => e
    raise unless on_api_failure == :warn

    warn "#{e.class}: #{e.message}"
    nil
  end
end
