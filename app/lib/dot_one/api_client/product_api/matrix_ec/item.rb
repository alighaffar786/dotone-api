module DotOne::ApiClient::ProductApi::MatrixEC
  class Item < DotOne::ApiClient::ProductApi::BaseItem
    include DotOne::ApiClient::ProductApi::ItemHelper

    def initialize(client_api, options = {})
      @client_api = client_api
      build_product_data(options)
    end

    def category_1
      @category_1 ||= options[:google_product_category]
    end

    def additional_data
      @additional_data ||= build_additional_data
    end

    private

    def build_product_data(options)
      super(options)
      @product_data[:additional_attributes] = additional_data
      @product_data[:uniq_key] = to_uniq_key
      @product_data
    end

    def build_additional_data
      result = {}
      result[:color] = options[:color] if options[:color].present?
      result[:size] = options[:size] if options[:size].present?
      result
    end
  end
end
