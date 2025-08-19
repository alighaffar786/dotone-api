module DotOne::ApiClient::ProductApi
  module ItemHelper
    # TODO: : Get locale from user input
    def locale
      @locale ||= options[:locale] || Language.platform_locale.upcase
    end

    def currency
      @currency ||= determine_currency || Currency.platform_code
    end

    def offer_id
      @offer_id ||= options[:offer_id]
    end

    def client_id_value
      @client_id_value ||= options[:id]
    end

    def title
      @title ||= options[:title]
    end

    def description_1
      @description_1 ||= options[:description]
    end

    def category_id
      @category_id ||= cleanup_str(options[:google_product_category])
    end

    def category_map_given?
      options[:category_map].present?
    end

    def category_map
      @category_map ||= options[:category_map] || {}
    end

    def categories
      @categories ||= category_map[category_id]
    end

    def category_1
      @category_1 ||= if category_map_given?
        categories.try(:[], :category_1) || options[:product_type]
      else
        options[:product_type]
      end
    end

    def category_2
      @category_2 ||= if category_map_given?
        categories.try(:[], :category_2)
      else
        options[:category_2]
      end
    end

    def category_3
      @category_3 ||= if category_map_given?
        categories.try(:[], :category_3)
      else
        options[:category_3]
      end
    end

    def product_url
      @product_url ||= options[:link]
    end

    def brand
      @brand ||= options[:brand]
    end

    def is_new?
      cleanup_str(options[:condition]) == 'new'
    end

    def is_promotion?
      price > 0 && sale_price > 0 && price > sale_price
    end

    def inventory_status
      @inventory_status ||= begin
        availability = cleanup_str(options[:availability])

        if ['in stock', 'in_stock', '有現貨'].include?(availability)
          'In Stock'
        else
          'Out of Stock'
        end
      end
    end

    def price
      @price ||= options[:price].to_s.gsub(/,/, '').to_f
    end

    def sale_price
      @sale_price ||= options[:sale_price].to_s.gsub(/,/, '').to_f
    end

    def discount
      @discount ||= price - sale_price
    end

    def image_data
      @image_data ||= build_image_data
    end

    def price_data
      @price_data ||= build_price_data
    end

    private

    attr_reader :options

    def build_product_data(options)
      @options = options.with_indifferent_access
      @product_data = {
        locale: locale,
        currency: currency,
        offer_id: offer_id,
        client_id_value: client_id_value,
        title: title,
        description_1: description_1,
        category_1: category_1,
        category_2: category_2,
        category_3: category_3,
        product_url: product_url,
        brand: brand,
        is_new: is_new?,
        is_promotion: is_promotion?,
        inventory_status: inventory_status,
        prices: price_data,
        images: image_data,
        client_api_id: client_api.id,
      }
      @product_data
    end

    def build_price_data
      price_data = initialize_price_data
      price_data[:retail] = converted_price_value_map(price)

      price_data[:sale] = converted_price_value_map(sale_price) if sale_price > 0

      price_data[:discount] = converted_price_value_map(discount) if is_promotion?

      price_data
    end

    def build_image_data
      [options[:image_link]].compact
    end

    def determine_currency
      return unless price = options[:price]

      currency = price.gsub(/[^a-zA-Z]/, '').upcase
      currency if Currency.currency_valid?(currency)
    end

    def cleanup_str(str)
      str.try(:downcase).try(:squish)
    end

    def converted_price_value_map(value)
      DotOne::Utils::CurrencyConverter.convert_to_all(currency, value)
    end
  end
end
