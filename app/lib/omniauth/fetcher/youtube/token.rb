require 'google/api_client/client_secrets'

class OmniAuth::Fetcher::Youtube::Token
  attr_accessor :auth

  def initialize(opts = {})
    code = opts[:code]
    refresh_token = opts[:refresh_token]

    @client_secrets = Google::APIClient::ClientSecrets.new(credentials)
    @auth = @client_secrets.to_authorization

    @auth.update!({
      scope: 'https://www.googleapis.com/auth/youtube.readonly',
      access_type: 'offline',
      code: code,
      refresh_token: refresh_token,
    })

    @auth.fetch_access_token!
  rescue Signet::AuthorizationError => e
    raise OmniAuth::Fetcher::Error::TokenError, e.message
  end

  private

  def credentials
    {
      web: {
        client_id: ENV.fetch('GOOGLE_CLIENT_ID', nil),
        client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
        redirect_uris: [DotOne::ClientRoutes.affiliates_youtube_callback_url],
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
      },
    }
  end
end
