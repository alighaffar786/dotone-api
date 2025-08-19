module DotOne::ApiClient::ProductApi::YahooBuy
  ##
  # Class represents each of Yahoo Buy's product item.

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, options = {}, item_options = {})
      options = options.with_indifferent_access

      @client_api = client_api

      client_id_value = Digest::SHA1.hexdigest(options[:url])
      category_map = item_options[:category_map]
      currency_rate_map = item_options[:currency_rate_map]

      categories = []
      options[:categoryPath].split(',').each do |c|
        categories << category_map[c]
      end

      promo_start = Time.at(options[:promo][:startTime]) rescue nil
      promo_end = Time.at(options[:promo][:endTime]) rescue nil

      is_promotion = determine_is_promotion(options)

      @locale = Language.platform_locale.upcase
      @currency = Currency.platform_code

      @product_data = {
        client_id_value: client_id_value,
        universal_id_value: nil,
        title: options[:title],
        description_1: options[:description],
        description_2: nil,
        brand: nil,
        category_1: categories[0],
        category_2: categories[1],
        category_3: categories[2],
        product_url: options[:url],
        is_new: determine_is_new(options),
        is_promotion: is_promotion,
        promo_start_at: promo_start,
        promo_end_at: promo_end,
        inventory_status: 'In Stock',
        locale: @locale,
        currency: @currency,
        offer_id: options[:offer_id],
        client_api_id: client_api.id,
      }

      @product_data[:uniq_key] = to_uniq_key

      # Original amount is in TWD
      retail_price = options[:price].present? ? options[:price].to_f : nil
      sale_price = nil
      discount_price = nil
      if is_promotion
        sale_price = options[:promo][:price].present? ? options[:promo][:price].to_f : nil rescue nil
        discount_price = retail_price.to_f - sale_price.to_f
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

      # Figure out product image
      @image_data = []
      @image_data << options[:imageUrl]

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = @image_data
    end

    private

    def determine_is_new(options = {})
      return if options[:createDate].blank?

      create_time = Time.at(options[:createDate].to_i) rescue nil
      return unless create_time.present?

      (Time.now - create_time) <= 14.days
    end

    def determine_is_promotion(options = {})
      return false if options[:promo].blank?
      return false if options[:promo][:startTime].blank?
      return false if options[:promo][:endTime].blank?

      start_time = Time.at(options[:promo][:startTime].to_i)
      end_time = Time.at(options[:promo][:endTime].to_i)
      return unless start_time.present? && end_time.present?

      Time.now > start_time && Time.now < end_time
    end
  end
end
