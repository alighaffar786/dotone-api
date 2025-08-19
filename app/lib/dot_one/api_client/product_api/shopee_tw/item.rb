module DotOne::ApiClient::ProductApi::ShopeeTw
  class Item < DotOne::ApiClient::ProductApi::BaseItem
    include DotOne::ApiClient::ProductApi::ItemHelper

    def initialize(client_api, options = {})
      @client_api = client_api
      build_product_data(options)
    end

    def currency
      Currency.platform_code
    end

    def description_1
      @options[:product_description]
    end

    def category_1
      @options[:category1]
    end

    def category_2
      @options[:category2]
    end

    def category_3
      @options[:category3]
    end

    def is_new?
      BooleanHelper.truthy?(@options[:condition])
    end

    def inventory_status
      @options[:stock].to_i > 0 ? 'In Stock' : 'Out of Stock'
    end

    def build_image_data
      [
        @options[:image_link],
        @options[:additional_image_link],
      ].compact
    end

    private

    def build_product_data(options)
      super(options)
      @product_data[:uniq_key] = to_uniq_key(@options[:id])
      @product_data
    end
  end
end
