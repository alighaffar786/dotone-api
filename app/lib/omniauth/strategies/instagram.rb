module OmniAuth
  module Strategies
    class Instagram < OmniAuth::Strategies::OAuth2
      include ExceptionHelper
      class NoAuthorizationCodeError < StandardError; end

      DEFAULT_SCOPE = 'user_profile,user_media'.freeze
      USER_INFO_URL = 'https://graph.instagram.com/me'.freeze
      BASE_GRAPH_URL = 'https://graph.instagram.com'.freeze

      FB_ERROR_USER_NOT_FOUND = 110

      option :name, 'instagram'

      option :client_options, {
        site: 'https://api.instagram.com',
        authorize_url: 'https://api.instagram.com/oauth/authorize',
        token_url: 'oauth/access_token',
      }

      option :authorize_options, [:scope, :display, :auth_type]

      uid { raw_info['id'] }

      info do
        prune!({
          'nickname' => raw_info['username'],
          'name' => raw_info['username'],
        })
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= user_info
          .merge(site_info: site_info) # .merge(media_info) # disabled media_info scope for now
      end

      def user_info
        @user_info ||= begin
          info_options = { params: { fields: 'account_type,id,media_count,username' } }
          access_token.get("#{BASE_GRAPH_URL}/me", info_options).parsed || {}
        end
      end

      def media_info
        @media_info ||= begin
          info_options = { params: { fields: 'id,timestamp' } }
          res = access_token.get("#{BASE_GRAPH_URL}/me/media", info_options).parsed || {}
          { media: res['data'] }
        end
      end

      def site_info
        {
          url: "https://instagram.com/#{user_info['username']}",
          username: user_info['username'],
          account_id: user_info['id'],
          account_type: SiteInfo.account_type_basic_instagram,
          description: "Instagram Account (#{user_info['username']})",
          media_categories: media_categories,
          instagram_type: user_info['account_type'],
        }.merge(site_info_metrics)
      end

      def site_info_metrics
        {
          access_token: access_token.token,
          followers_count: followers_count,
          media_count: user_info['media_count'],
          # last_media_posted_at: media_info.dig(:media, 0, 'timestamp'), # disabled media_info scope for now
        }
      end

      # You can pass +scope+ param to the auth request, if you need to set them dynamically.
      # You can also set these options in the OmniAuth config :authorize_params option.
      def authorize_params
        super.tap do |params|
          ['scope'].each do |v|
            params[v.to_sym] = request.params[v] if request.params[v]
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      def callback_url
        uri = URI(options[:callback_url])
        uri.scheme = 'https' # enforce https
        uri.to_s
      end

      def build_access_token
        exchange = exchange_code
        short = short_lived_client.get_token(access_token: exchange.token, grant_type: 'ig_exchange_token', client_secret: client.secret)
        long_lived_client.get_token(access_token: short.token, grant_type: 'ig_refresh_token')
      end

      def build_refresh_token(refresh_token)
        self.access_token = long_lived_client.get_token(access_token: refresh_token, grant_type: 'ig_refresh_token')
      end

      protected

      def exchange_code
        verifier = request.params['code']
        params = {
          redirect_uri: callback_url,
          client_id: options.client_id,
          client_secret: options.client_secret,
        }
        client.auth_code.get_token(verifier, params, {})
      end

      private

      def graph
        Koala::Facebook::API.new(wl_facebook_access_token)
      end

      def followers_count
        discovery.dig('business_discovery', 'followers_count') || 0
      end

      def discovery
        @discovery ||= begin
          graph.get_object("#{wl_instagram_id}?fields=business_discovery.username(#{user_info['username']}){followers_count}")
        rescue Koala::Facebook::ClientError => e
          # will error if the user is personal account type
          Sentry.capture_exception(e) unless e.fb_error_code == FB_ERROR_USER_NOT_FOUND

          if e.fb_error_code == 190
            @wl_facebook_access_token = DotOne::Setup.wl_company.refresh_facebook_access_token

            retry
          else
            catch_exception { raise e }
          end

          {}
        end
      end

      def wl_instagram_id
        @wl_instagram_id ||= DotOne::Setup.wl_setup(:facebook_instagram_id)
      end

      def wl_facebook_access_token
        @wl_facebook_access_token ||= DotOne::Setup.wl_setup(:facebook_access_token)
      end

      def long_lived_client
        ::OAuth2::Client.new(client.id, client.secret, {
          site: 'https://graph.instagram.com',
          token_url: '/refresh_access_token',
          authorize_url: nil,
          token_method: :get,
        })
      end

      def short_lived_client
        ::OAuth2::Client.new(client.id, client.secret, {
          site: 'https://graph.instagram.com',
          token_url: '/access_token',
          authorize_url: nil,
          token_method: :get,
        })
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def media_categories
        AffiliateTag.media_categories.where(name: 'Instagram')
      end
    end
  end
end
