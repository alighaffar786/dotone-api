# VibrantAds created OmniAuth Strategy for LINE
# Reasons we can NOT use omniauth-line:
# 1. omniauth-line is locked on omniauth-oauth2 '~> 1.3.1' due to lack of maintenance
# 2. omniauth-google-oauth2 with non-legacy API requires omniauth-oauth2 '>= 1.5'
# Downgrading omniauth-oauth2 to '~> 1.3.1' will force us to use omniauth-google-oauth2 '~> 0.2.6'
# omniauth-google-oauth2 '~> 0.2.6' uses the Legacy API which only works with legacy accounts
# 3. omniauth-line does not have the functionality to retrieve user email
# 4. omniauth-line does not have the functionality to use redirect_uri based on request host
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :name, 'line'
      option :scope, 'profile openid email'

      option :client_options, {
        site: 'https://access.line.me',
        authorize_url: '/oauth2/v2.1/authorize',
        token_url: '/oauth2/v2.1/token',
      }

      uid { raw_info['userId'] }

      info do
        {
          first_name: raw_info['firstName'],
          last_name: raw_info['lastName'],
          image: raw_info['pictureUrl'],
          description: raw_info['statusMessage'],
          email: id_info['email'],
        }
      end

      extra { id_info }

      def raw_info
        @raw_info ||= get_profile_info
      end

      def id_info
        @id_info ||= decode_id_token
      end

      # LINE API encodes user email in their JWT id_token
      # We decode the id_token and retrieve user email from it
      # gem 'omniauth-line' does not have this implemented
      def decode_id_token
        return {} unless access_token['id_token'].present?

        decoded = JWT.decode(access_token['id_token'], nil, false).first

        JWT::Verify.verify_claims(decoded,
          verify_iss: true,
          iss: 'https://access.line.me',
          verify_aud: true,
          aud: options.client_id,
          verify_sub: false,
          verify_expiration: true,
          verify_not_before: true,
          verify_iat: true,
          verify_jti: false)
        prune!(decoded)
      end

      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def get_profile_info
        info = JSON.parse(access_token.get('v2/profile').body)
        arr = info['displayName'].to_s.squish.split(/\s+/)
        info['firstName'] = arr.shift
        info['lastName'] = arr.try(:join, ' ')
        info
      end

      def callback_phase
        options[:client_options][:site] = 'https://api.line.me'
        super
      end

      # Make sure middleware is configured to use request host for the redirect_uri
      # gem 'omniauth-line' does not have this implemented
      def callback_url
        options[:redirect_uri] || super
      end
    end
  end
end
