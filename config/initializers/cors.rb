# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  ALLOWED_PUBLIC_HOSTS = ['vibrantads.com']
  ALLOWED_API_CLIENT_HOSTS = ['affiliates.one']

  if Rails.env.production?
    allow do
      origins '*'
      resource "/api/v2/affiliates/ad_links/*", headers: :any, methods: [:get, :post, :options]
      resource "/api/v2/affiliates/links/*", headers: :any, methods: [:get, :post, :options]
    end

    allow do
      origins '*'
      resource '/public/*',
        headers: :any,
        methods: [:post, :options, :head],
        if: proc { |env| ALLOWED_PUBLIC_HOSTS.any? { |host| env['HTTP_ORIGIN'].include?(host) } }
    end

    allow do
      origins '*'
      resource /\/api\/(client|v2)\/.*/,
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        if: proc { |env| ALLOWED_API_CLIENT_HOSTS.any? { |host| env['HTTP_ORIGIN'].include?(host) } }
    end
  else
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
end
