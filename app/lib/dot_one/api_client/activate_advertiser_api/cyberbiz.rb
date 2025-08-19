require 'net/https'
require 'digest'
require 'time'

module DotOne::ApiClient::ActivateAdvertiserApi
  module Cyberbiz
    class Client
      USERNAME = 'affiliates'
      SECRET = '9HIInQTyPSwmeycmVOMBukiehTZZ7tAy'

      attr_accessor :advertiser

      def initialize(_options = {})
        @url_format = 'https://api-cyberbiz-store.cyberbiz.co/v1/shop_add_ons/-adv_partner_app_token-'
      end

      def request_uri
        return if @url_format.blank? || @advertiser.blank?
        return @request_uri if @request_uri.present?

        uri_string = @advertiser.format_content(@url_format, :url)
        @request_uri = URI(uri_string) rescue nil
        @request_uri
      end

      def request_http
        return @http if @http.present?

        @http = nil
        uri = request_uri
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
        post_parameters = {
          status: install_status,
          start_at: @advertiser.active_at.to_s(:db),
        }

        request = Net::HTTP::Put.new(request_uri.request_uri)
        request.set_form_data(post_parameters)
        request['X-Date'] = Time.now.httpdate
        request['Digest'] = generate_digest
        request['Authorization'] = generate_authorization

        response = request_http.request(request)

        {
          url: request_uri.request_uri,
          parameters: post_parameters,
          request_body: { url: request_uri.request_uri, parameters: post_parameters },
          response_body: response.body,
        }
      end

      def install_status
        if @advertiser.active?
          'installed'
        elsif @advertiser.suspended?
          'apply_failed'
        end
      end

      def body_string
        return if @advertiser.blank? || @advertiser.active_at.blank?

        start_at = CGI.escape(@advertiser.active_at.to_s(:db)).gsub('+', '%20')
        "status=#{install_status}&start_at=#{start_at}"
      end

      def generate_digest
        "SHA-256=#{base64_body_string}"
      end

      def generate_authorization
        "hmac username=\"#{USERNAME}\", algorithm=\"hmac-sha256\", headers=\"x-date request-line digest\", signature=\"#{signature}\""
      end

      def signature
        sig_str = "x-date: #{request_timestamp}\nPUT /v1/shop_add_ons/1 HTTP/1.1\ndigest: SHA-256=#{base64_body_string}"
        Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', SECRET, sig_str))
      end

      def request_timestamp
        @request_timestamp ||= Time.now.httpdate
      end

      def base64_body_string
        @base64_body_string ||= Digest::SHA256.base64digest(body_string)
      end
    end
  end
end
