module DotOne::ApiClient::ProductApi::I3fresh
  ##
  # Class represents each of I3fresh's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, options = {})
      @client_api = client_api
      @additional_attributes = {}

      @locale = options[:locale] || Language.platform_locale.upcase
      @currency = options[:currency] || Currency.platform_code

      @product_data = {
        client_id_value: options[:id],
        universal_id_value: nil,
        title: options[:title],
        description_1: options[:description],
        product_url: options[:url],
        locale: @locale,
        currency: @currency,
        offer_id: options[:offer_id],
        client_api_id: client_api.id,
      }

      @product_data[:uniq_key] = to_uniq_key

      # Populate categories & description
      category_splits = options[:type_tw].split(',') rescue nil

      if category_splits.present?
        @product_data[:category_1] = category_splits[0]
        @product_data[:category_2] = category_splits[1]
        @product_data[:category_3] = category_splits[2]
      end

      # Populate price data
      retail_price = options[:retailprice].present? ? options[:retailprice].to_f : nil
      sale_price = options[:price].present? ? options[:price].to_f : nil
      discount_price = retail_price.to_f - sale_price.to_f
      @price_data = initialize_price_data

      [
        [retail_price, :retail],
        [sale_price, :sale],
        [discount_price, :discount],
      ].each do |price|
        if price[0].present?
          @price_data[price[1]] = DotOne::Utils::CurrencyConverter.convert_to_all(@currency, price[0])
        end
      end

      # Figure out product image
      @image_data = []
      @image_data << options[:img_url]

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = @image_data
      @product_data[:additional_attributes] = @additional_attributes
    end

    private

    def enforce_encoding(str)
      str.encode(Encoding.find('UTF-8'), { invalid: :replace, undef: :replace, replace: '' })
    end
  end
end
