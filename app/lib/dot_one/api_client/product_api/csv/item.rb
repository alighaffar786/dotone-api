module DotOne::ApiClient::ProductApi::Csv
  class Item < DotOne::ApiClient::ProductApi::BaseItem
    include DotOne::ApiClient::ProductApi::ItemHelper

    def initialize(client_api, options = {})
      @client_api = client_api
      build_product_data(options)
    end

    private

    def build_product_data(options)
      super(options)
      @product_data[:uniq_key] = to_uniq_key
      @product_data
    end
  end
end
