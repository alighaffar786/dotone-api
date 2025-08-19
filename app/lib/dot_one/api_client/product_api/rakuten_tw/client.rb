require 'net/ftp'
require 'nokogiri'
require 'zip'

module DotOne::ApiClient::ProductApi::RakutenTw
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def download; end

    def to_items(options = {})
      page = 1
      loop do
        data = products(page)
        break if data.empty?

        data.each_with_index do |row, index|
          product = row.merge(offer_id: related_offer.id).with_indifferent_access
          item = DotOne::ApiClient::ProductApi::RakutenTw::Item.new(options[:client_api], product)
          item_collection.push(item, options)
          item_collection.process(index, options)
        end

        item_collection.process(0, options.merge(flush: true))
        page += 1
      end
    end

    def access_token
      @access_token ||= begin
        response, code = api(
          access_token: true,
          method: :post,
          path: 'productFeed/v2/getAccessToken',
          payload: {
            clientId: username,
            password: password,
          }.to_json
        )

        if response['accessToken']
          response['accessToken']
        else
          raise StandardError.new("code: #{code} response: #{response.to_json}")
        end
      end
    end

    def api(options = {})
      sleep 20
      uri = URI.parse("https://twapi.rakuten.tw/#{options.delete(:path)}")
      uri.query = URI.encode_www_form(options.delete(:params)) if options[:params].present?

      options[:method] ||= :get
      options[:url] = uri.to_s
      options[:headers] = { content_type: :json, accept: :json }
      options[:headers].merge!(authorization: "RKT-TOKEN #{access_token}") unless options.delete(:access_token)

      response = RestClient::Request.execute(options)

      [JSON.parse(response.body), response.code]
    end

    def products(page, retries = 0)
      limit = 1000
      params = { offset: (page - 1) * limit, limit: limit, clientId: username }
      retry_exceed = retries > 5
      response, code = api(path: 'productFeed/v2/productFull', params: params)

      if code == 200
        response['data']
      elsif code == 401 && response['error']&.match('clientId or accessToken not correct') && !retry_exceed
        @access_token = nil
        products(page, retries + 1)
      elsif code == 429 && !retry_exceed
        sleep 20
        products(page, retries + 1)
      else
        raise StandardError.new("code: #{code} response: #{response.to_json}")
      end
    end
  end
end
