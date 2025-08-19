advertiser_order_api_path = Regexp.new('/api/v2/advertisers/orders/(modify|nine_one_app)')
advertiser_easystore_webhook_path = Regexp.new('/api/v2/advertisers/webhook/easy_stores/(update|reject)')

Rack::Attack.throttle('Affiliate API', limit: 1, period: 60.seconds) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.

  # Exclude ad_links from throttle as request is triggered by user visit
  if req.path.include?('/api/v2/affiliates') && !req.path.include?('/links/generate') && !req.path.include?('/ad_links/generate')
    "#{req.ip}:#{req.path}"
  end
end

Rack::Attack.throttle('Affiliate API: Adlink', limit: 2, period: 10.seconds) do |req|
  if req.path.include?('/api/v2/affiliates/links/generate') || req.path.include?('/api/v2/affiliates/ad_links/generate')
    "#{req.ip}:#{req.path}"
  end
end

# Rack::Attack.throttle('Advertiser API: Orders', limit: 1, period: 5.seconds) do |req|
#   if req.path.match(advertiser_order_api_path)
#     "#{req.ip}:#{req.path}"
#   end
# end

Rack::Attack.throttle('Advertiser API', limit: 1, period: 60.seconds) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.
  # Exclude offers from throttle as request is triggered by user visit
  if req.path.include?('/api/v2/advertisers') && !req.path.match(advertiser_order_api_path) && !req.path.match(advertiser_easystore_webhook_path)
    "#{req.ip}:#{req.path}"
  end
end

Rack::Attack.blocklist('Block IPs') do |req|
  # Requests are blocked if the return value is truthy
  [
    '191.101.132.12',
    '191.101.132.66',
    '5.181.86.94',
    '94.177.118.144',
    '94.232.41.156',
  ].include?(req.ip)
end

Rack::Attack.throttled_response = lambda do |env|
  [
    429,
    { 'Content-Type' => 'application/json' },
    [{ message: 'Rate limit exceeded. Please try again later.' }.to_json]
  ]
end
