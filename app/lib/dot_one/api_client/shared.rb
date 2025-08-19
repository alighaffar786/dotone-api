require 'net/http'
require 'open-uri'
require 'digest'
require 'csv'

module DotOne::ApiClient
  module Shared
    attr_accessor :auth_token, :http_method, :http_headers, :http_body

    def response
      uri = request_url
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.is_a?(URI::HTTPS)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.read_timeout = 300

      request = nil

      if http_method == :put
        request = Net::HTTP::Put.new(uri.request_uri)
      elsif http_method == :post
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = http_body if http_body.present?
      else
        request = Net::HTTP::Get.new(uri.request_uri)
      end

      request.basic_auth api_key, auth_token if auth_token.present?

      if http_headers.present?
        http_headers.each_pair do |key, value|
          request[key] = value
        end
      end

      response = http.request(request)
      response.body
    end

    def graphql_response(options = {})
      uri = graph_url
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.is_a?(URI::HTTPS)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Post.new(uri.request_uri, initheader = { 'Content-Type' => 'application/json' })

      request.body = if options[:method] == :assign_pid
        assign_pid_http_body.to_json
      else
        search_pid_http_body.to_json
      end

      request.basic_auth(api_key, auth_token)

      if http_headers.present?
        http_headers.each_pair do |key, value|
          request[key] = value
        end
      end

      response = http.request(request)
    end

    def to_json(*_args)
      JSON.parse(response)
    rescue JSON::ParserError
      {}
    end

    def log_error!(e, record = nil)
      return if e.message == 'Order is in final state'
      log_exception = ['No Click Stat', 'Order is in approved or rejected state']

      if log_exception.include?(e.message)
        ORDER_API_PULL_LOGGER.error "[#{Time.now}] Error: #{e.message} => #{record}"
      elsif e.is_a? DotOne::Errors::AffiliateStatNotFoundError
        ORDER_API_CLICK_STAT_MISSING_LOGGER.info "Order API #{client_api_id} => '#{e.click_id}' missing"
      else
        Sentry.capture_exception(e)
        ORDER_API_PULL_LOGGER.error "[#{Time.now}] Error: #{e.message}"
        ORDER_API_PULL_LOGGER.error "[#{Time.now}] #{e.backtrace.join("\r\n")}"
      end
    end
  end
end
