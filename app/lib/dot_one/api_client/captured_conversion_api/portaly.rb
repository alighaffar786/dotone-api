require 'net/https'

module DotOne::ApiClient::CapturedConversionApi
  module Portaly
    class Client
      attr_accessor :conversion_stat

      def initialize(options = {})
        @conversion_stat = nil
        @url_format = [options[:host], options[:path]].join
        @auth_token = options[:auth_token]
      end

      def request_uri
        URI(@url_format)
      end

      def request_http
        return @http if @http.present?

        uri = request_uri
        @http = nil

        if uri.is_a?(URI::HTTPS)
          @http = Net::HTTP.new(uri.host, uri.port)
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        else
          @http = Net::HTTP.new(uri.host, uri.port)
        end
        @http
      end

      def send!
        return if conversion_stat.blank? || conversion_stat.conversions.to_i < 1

        stat = V2::Affiliates::AffiliateStatSerializer.new(conversion_stat).as_json

        post_parameters = {
          meta: {
            currency: Currency.platform_code,
            time_zone: TimeZone.platform.gmt.to_i,
          },
          data: {
            transactions: [stat],
          },
        }

        timestamp = Time.now.utc.to_i
        json_body = post_parameters.to_json
        payload = "#{timestamp}:#{json_body}"
        signature = OpenSSL::HMAC.hexdigest('SHA256', @auth_token, payload)

        request = Net::HTTP::Post.new(request_uri.request_uri)
        request['Content-Type'] = 'application/json'
        request['Timestamp'] = timestamp
        request['Signature'] = signature
        request.body = json_body
        response = request_http.request(request)
        {
          request_body: request.body,
          response_body: response.body,
        }
      end
    end
  end
end
