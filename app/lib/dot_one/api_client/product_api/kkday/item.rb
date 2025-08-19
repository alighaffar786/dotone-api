module DotOne::ApiClient::ProductApi::Kkday
  ##
  # Class represents each of KK Day's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, options = {})
      @client_api = client_api
      @additional_attributes = {}

      @locale = options[:locale] || 'EN-US'
      @currency = options[:currency] || 'USD'

      api_client = DotOne::ApiClient::ProductApi::Kkday::Api.new({
        locale: @locale, currency: @currency
      })

      @product_data = {
        client_id_value: options[:prod_oid],
        universal_id_value: nil,
        title: options[:prod_desc],
        product_url: "https://www.kkday.com/zh-tw/product/#{options[:prod_oid]}",
        locale: @locale,
        currency: @currency,
        offer_id: options[:offer_id],
        client_api_id: client_api.id,
        inventory_status: options[:hot_sort] == '0' ? 'Out of Stock' : 'In Stock'
      }

      @product_data[:uniq_key] = to_uniq_key

      # Populate categories & description
      product_info = api_client.product_info(options[:prod_oid]) rescue nil

      if product_info.present? && product_info['content'].present?
        if product_info['content']['product'].present?
          @product_data[:category_1] = enforce_encoding(product_info['content']['product']['mainCatStr'])
          @product_data[:description_1] = enforce_encoding(product_info['content']['product']['productDesc'])
          @product_data[:description_2] = enforce_encoding(product_info['content']['product']['introduction'])
        end

        # Get tour area
        @additional_attributes[:city_list] = []

        if product_info['content']['cityList'].present?
          product_info['content']['cityList'].each do |city_hash|
            @additional_attributes[:city_list] << {
              country: city_hash.city.countryName,
              city: city_hash.city.cityName,
            }
          end
        end
      end

      # Get tour time
      [:tour_days, :tour_hours, :confirm_hour].each do |key|
        @additional_attributes[key] = options[key]
      end

      # Populate price data
      retail_price = options[:min_price].present? ? options[:min_price].to_f : nil
      @price_data = initialize_price_data

      [
        [retail_price, :retail],
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
