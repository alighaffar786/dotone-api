require 'net/https'

module DotOne::ApiClient::CapturedConversionApi
  module Post
    class Client
      attr_accessor :conversion_stat, :url_format, :request_body_content, :authorization

      def initialize(options = {})
        @conversion_stat = nil
        @url_format = [options[:host], options[:path]].join
        @request_body_format = options[:request_body_content]
        @authorization = options[:auth_token]
      end

      def request_uri
        return if @url_format.blank?
        return @request_uri if @request_uri.present?

        uri_string = @conversion_stat.format_pixel(@url_format)
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
        return if request_uri.blank?

        request = Net::HTTP::Post.new(request_uri.request_uri)
        request['Authorization'] = @authorization
        request['Content-Type'] = 'application/json'
        request.body = @conversion_stat.format_pixel(@request_body_format)
        response = request_http.request(request)
        {
          request_body: request.body,
          response_body: response.body,
        }
      end
    end
  end
end
