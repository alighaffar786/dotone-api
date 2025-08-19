module DotOne::ApiClient::ProductApi::RakutenTw
  ##
  # Class represents each of Rakuten TW's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, row = {}, _item_options = {})
      @client_api = client_api

      @locale = Language.platform_locale.upcase
      @currency = Currency.platform_code

      @product_data = {
        client_id_value: row[:product_id],
        universal_id_value: nil,
        title: row[:product_name],
        description_1: row[:description],
        description_2: row[:l_description],
        brand: row[:shop_name],
        category_1: row[:product_category_value],
        category_2: nil,
        category_3: nil,
        product_url: row[:link],
        is_new: nil,
        is_promotion: determine_is_promotion(row),
        promo_start_at: nil,
        promo_end_at: nil,
        inventory_status: determine_inventory_status(row),
        locale: @locale,
        currency: @currency,
        offer_id: row[:offer_id],
        client_api_id: client_api.id,
      }

      @product_data[:uniq_key] = to_uniq_key(row[:product_id])

      # Original amount is in TWD
      retail_price = row[:price].to_f
      sale_price = row[:sale_price].to_f

      if retail_price.present? && sale_price.present?
        discount_price = retail_price.to_f - sale_price.to_f
      end

      # Not all market price (retail price) is present.
      # When that's the case, we do not want to show
      # negative discount price
      if discount_price < 0.0
        retail_price = sale_price
        sale_price = 0.0
        discount_price = 0.0
      end

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

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = [row[:image_link]]
    end

    private

    def determine_is_promotion(row = {})
      return false if row[:sale_price].blank? || row[:price].blank?

      retail_price = row[:price].to_f
      sale_price = row[:sale_price].to_f
      retail_price > sale_price
    end

    def determine_inventory_status(row = {})
      if row[:availability] == 'in stock'
        'In Stock'
      elsif row[:availability] == 'out of stock'
        'Out of Stock'
      end
    end
  end
end
