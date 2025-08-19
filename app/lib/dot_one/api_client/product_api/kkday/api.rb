require 'net/http'
require 'open-uri'

module DotOne::ApiClient::ProductApi::Kkday
  class Api
    attr_accessor :api_key, :locale, :currency, :user_oid

    def initialize(options = {})
      @api_key = options[:api_key] || api_key

      @locale = options[:locale] || 'en'
      if @locale == 'EN-US'
        @locale = 'en'
      elsif @locale == 'KO-KR'
        @locale = 'ko'
      elsif @locale == 'JA-JP'
        @locale = 'ja'
      end

      @currency = options[:currency] || 'USD'
      @user_oid = options[:user_oid] || 2318
    end

    ##
    # Access KKDay's product detail information.
    # Return value is parsed to JSON
    def product_info(oid)
      uri = URI::HTTPS.build({
        host: 'api.kkday.com',
        path: "/api/product/info/fe/v1/#{oid}",
      })

      additional_data = {}

      begin
        json_response = response(uri, additional_data)
        JSON.parse(json_response)
      rescue StandardError
      end
    end

    private

    def api_key
      if Rails.env == 'development'
        'd42b198b922500975afd28a31f8c1cc6'
      else
        '6477e36fce48e267eea7f3f90cadb821'
      end
    end

    def ip_address
      if Rails.env == 'development'
        '68.96.221.240'
      else
        '54.83.207.160'
      end
    end

    def response(uri, additional_data = {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = {
        apiKey: api_key,
        userOid: '2318',
        ver: '1.0.1',
        locale: locale.downcase,
        ipaddress: ip_address,
        currency: currency,
        json: additional_data,
      }.to_json

      response = http.request(request)
      response.body
    end
  end
end
