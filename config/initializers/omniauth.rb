require './app/lib/omniauth/strategies/google_oauth2'
require './app/lib/omniauth/strategies/facebook'

FACEBOOK_PERMISSIONS = [
  'user_gender',
  'public_profile',
  'email',
  'pages_show_list',
  'instagram_basic',
  # 'instagram_manage_insights',
  # 'read_insights',
  'pages_read_engagement',
  'user_birthday',
  # 'business_management',
].join(',')

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  configure do |config|
    config.path_prefix = '/api/client/affiliates/auth'
    config.logger = Rails.logger
  end

  provider :facebook, ENV.fetch('FACEBOOK_APP_ID'), ENV.fetch('FACEBOOK_APP_SECRET'),
    scope: FACEBOOK_PERMISSIONS,
    info_fields: 'email, first_name, last_name, location{location}, gender, birthday',
    image_size: { width: 300, height: 300 },
    secure_image_url: true,
    authorization_code_from_signed_request_in_cookie: true,
    provider_ignores_state: true,
    request_path: proc { |env|
      env['PATH_INFO'].starts_with?('/api/client/affiliates/auth/facebook') ||
        env['PATH_INFO'].starts_with?('/api/client/affiliates/auth/site_infos/facebook')
    },
    callback_path: proc { |env|
      env['PATH_INFO'].starts_with?('/api/client/affiliates/auth/facebook/callback') ||
        env['PATH_INFO'].starts_with?('/api/client/affiliates/auth/site_infos/facebook/callback')
    }

  provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID'), ENV.fetch('GOOGLE_CLIENT_SECRET'),
    scope: 'email,profile,https://www.googleapis.com/auth/user.gender.read,https://www.googleapis.com/auth/user.birthday.read',
    provider_ignores_state: true

  provider :instagram, ENV.fetch('INSTAGRAM_APP_ID'), ENV.fetch('INSTAGRAM_APP_SECRET'),
    provider_ignores_state: true,
    callback_url: DotOne::ClientRoutes.affiliates_instagram_callback_url, # client calback url
    request_path: '/api/client/affiliates/auth/site_infos/instagram/callback' # path for OmniAuth middleware to run

  provider :line, ENV.fetch('LINE_CLIENT_ID'), ENV.fetch('LINE_CLIENT_SECRET'),
    provider_ignores_state: true,
    redirect_uri: DotOne::ClientRoutes.affiliates_line_callback_url
end

OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
