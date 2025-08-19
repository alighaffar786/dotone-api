module DotOne::ApiClient::ProductApi::Check2check
  ##
  # Class represents each of Check2check's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, options = {})
      @client_api = client_api
      @additional_attributes = {}

      @locale = options[:locale] || 'EN-US'
      @currency = options[:currency] || 'USD'

      @product_data = {
        client_id_value: options[:id],
        universal_id_value: nil,
        title: options[:title],
        product_url: options[:link],
        locale: @locale,
        currency: @currency,
        offer_id: options[:offer_id],
        description_1: options[:description],
        client_api_id: client_api.id,
      }

      @product_data[:is_new] = options[:condition] == 'new'

      @product_data[:inventory_status] = if options[:availability] == 'in stock'
        'In Stock'
      else
        'Out of Stock'
      end

      @product_data[:is_promotion] = (options[:price].to_f - options[:sale_price].to_f) > 0

      # Populate category
      if options[:product_type].present?
        sanitized_product_type = ActionView::Base.full_sanitizer.sanitize(options[:product_type])
        product_types = sanitized_product_type.split('>').map { |x| x.strip }
        @product_data[:category_1] = product_types[0]
        @product_data[:category_2] = product_types[1]
        @product_data[:category_3] = product_types[2]
      end

      @product_data[:uniq_key] = to_uniq_key

      # Populate price data
      retail_price = options[:price].present? ? options[:price].to_f : nil
      sale_price = options[:sale_price].present? ? options[:sale_price].to_f : nil
      discount_price = retail_price - sale_price

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
      @image_data << options[:image_link]

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = @image_data
      @product_data[:additional_attributes] = @additional_attributes
    end
  end
end
