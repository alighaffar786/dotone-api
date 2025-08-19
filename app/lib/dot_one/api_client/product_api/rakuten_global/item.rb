require 'nokogiri'

module DotOne::ApiClient::ProductApi::RakutenGlobal
  ##
  # Class represents each of Linkshare's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, product_node, options = {})
      @client_api = client_api

      @product_data = {}

      [
        [:client_id_value, '@sku_number'],
        [:universal_id_value, 'upc'],
        [:title, '@name'],
        [:description_1, 'description/short'],
        [:description_2, 'description/long'],
        [:brand, 'brand'],
        [:category_1, 'category/primary'],
        [:category_2, 'category/secondary'],
        [:product_url, 'URL/product'],

      ].each do |attribute, xpath_string|
        @product_data[attribute] = product_node.at_xpath(xpath_string)&.content
      end

      @product_data[:inventory_status] = determine_inventory_status(product_node)
      @product_data[:is_promotion] = determine_is_promotion(product_node)

      @locale = if options[:default_locale].present?
        options[:default_locale].upcase
      else
        'EN-US'
      end

      @product_data[:locale] = @locale

      @product_data[:currency] = product_node.at_xpath('price/@currency')&.content
      @product_data[:currency] = options[:default_currency] if @product_data[:currency].blank?

      @currency = @product_data[:currency]

      @product_data[:uniq_key] = to_uniq_key

      @product_data[:offer_id] = options[:offer_id]

      @product_data[:client_api_id] = client_api.id

      # Figure out the price conversion
      @price_data = initialize_price_data

      if content = product_node.at_xpath('price/retail')&.content
        retail_price = content.to_f
      end

      if content = product_node.at_xpath('price/sale')&.content
        sale_price = content.to_f
      end

      if content = product_node.at_xpath('price/@currency')&.content
        price_currency = content.to_sym
      end

      if price_currency.present?
        if retail_price.present? && sale_price.present?
          discount_price = retail_price.to_f - sale_price.to_f
        end

        @price_data[:retail][price_currency] = retail_price if retail_price.present?
        @price_data[:sale][price_currency] = sale_price if sale_price.present?
        @price_data[:discount][price_currency] = discount_price if discount_price.present?
      end

      [
        [retail_price, :retail],
        [sale_price, :sale],
        [discount_price, :discount],
      ].each do |price|
        if price[0].present?
          @price_data[price[1]] = DotOne::Utils::CurrencyConverter.convert_to_all(price_currency, price[0])
        end
      end

      # Figure out product image
      @image_data = []
      if content = product_node.at_xpath('URL/productImage')&.content
        @image_data << content
      end

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = @image_data
    end

    private

    def determine_is_promotion(node)
      retail_price = node.at_xpath('price/retail')&.content
      sale_price = node.at_xpath('price/sale')&.content
      return false if retail_price.blank? || sale_price.blank?

      retail_price.to_f > sale_price.to_f
    end

    def determine_inventory_status(node)
      availability = node.at_xpath('shipping/availability')&.content
      'In Stock' if availability == 'in-stock'
    end
  end
end
