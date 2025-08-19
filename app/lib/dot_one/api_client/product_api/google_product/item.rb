module DotOne::ApiClient::ProductApi::GoogleProduct
  class Item < DotOne::ApiClient::ProductApi::BaseItem
    include DotOne::ApiClient::ProductApi::ItemHelper

    def initialize(client_api, options = {})
      @client_api = client_api
      build_product_data(options)
    end

    def product_url
      @product_url ||= if options[:link].is_a?(Array)
        options[:link][0]
      else
        options[:link]
      end
    end

    private

    def build_product_data(options)
      super(options)
      @product_data[:uniq_key] = to_uniq_key
      @product_data
    end

    def build_image_data
      [
        options[:image_link],
        options[:additional_image_link],
      ].flatten.compact
    end

  end
end
