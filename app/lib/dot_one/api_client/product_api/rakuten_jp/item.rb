module DotOne::ApiClient::ProductApi::RakutenJp
  ##
  # Class represents each of Linkshare's product item.
  #
  # Example of a product line:
  # 11543387968|V.A. Cd10929 Release|ajewelry:vicl-63562|Animals & Pet Supplies||http://click.linksynergy.com/link?id=CrWs39duuW8&offerid=508728.11543387968&type=15&murl=http%3A%2F%2Fglobal.rakuten.com%2Fen%2Fstore%2Fajewelry%2Fitem%2Fvicl-63562%3Fhi_cu_id%3Dusd%26sclid%3Daf_gl_lnk_linkshare_paid_%2BCD%25E3%2583%25BBDVD%25E3%2583%25BB%25E6%25A5%25BD%25E5%2599%25A8%2B%253E%2BCD%2B%253E%2B%25E3%2583%2580%25E3%2583%25B3%25E3%2582%25B9%25E3%2583%259F%25E3%2583%25A5%25E3%2583%25BC%25E3%2582%25B8%25E3%2583%2583%25E3%2582%25AF%2B%253E%2B%25E3%2583%2586%25E3%2582%25AF%25E3%2583%258E%25E3%2583%25BB%25E3%2583%25AA%25E3%2583%259F%25E3%2583%2583%25E3%2582%25AF%25E3%2582%25B9%25E3%2583%25BB%25E3%2583%258F%25E3%2582%25A6%25E3%2582%25B9%2B%253E%2B%25E3%2581%259D%25E3%2581%25AE%25E4%25BB%2596%26pup_e%3D1%26pup_cid%3D47561%26pup_id%3Dajewelry%25253Avicl-63562|http://thumbnail.image.rakuten.co.jp/@0_mall/ajewelry/cabinet/cddvd17/vicl-63562.jpg?_ex=700x700||130 Mm Diameter X Height 300 Mm Pipe Type Acrylic Case This Product (pipe Type Acrylic Case Height Sizes Available|130 Mm Diameter X Height 300 Mm Pipe Type Acrylic Case This Product (pipe Type Acrylic Case Height Sizes Available||amount|18|18|||ajewelry|||5213964844|||あり||60|USD||http://ad.linksynergy.com/fs-bin/show?id=CrWs39duuW8&bids=508728.11543387968&type=15&subid=0|||OSFA||multi|unisex||adult|||U

  class Item < DotOne::ApiClient::ProductApi::BaseItem
    def initialize(client_api, product_line, options = {})
      @client_api = client_api

      @product_data = {}
      @product_data[:client_id_value] = product_line[0]
      @product_data[:title] = product_line[1]
      @product_data[:universal_id_value] = product_line[2]
      @product_data[:category_1] = product_line[3]
      @product_data[:category_2] = product_line[4]
      @product_data[:product_url] = product_line[5]
      @product_data[:description_1] = product_line[8]
      @product_data[:description_2] = product_line[9]
      @product_data[:brand] = product_line[16]

      product_hash = {}
      product_hash[:sale_price] = product_line[12]
      product_hash[:retail_price] = product_line[13]
      product_hash[:currency] = product_line[25]
      product_hash[:image_url] = product_line[6]

      @product_data[:inventory_status] = determine_inventory_status(product_hash)
      @product_data[:is_promotion] = determine_is_promotion(product_hash)

      @locale = if options[:default_locale].present?
        options[:default_locale].upcase
      else
        'EN-US'
      end

      @product_data[:locale] = @locale

      @product_data[:currency] = product_hash[:currency]
      @product_data[:currency] = options[:default_currency] if @product_data[:currency].blank?

      @currency = @product_data[:currency]

      @product_data[:uniq_key] = to_uniq_key

      @product_data[:offer_id] = options[:offer_id]

      @product_data[:client_api_id] = client_api.id

      # Figure out the price conversion
      @price_data = initialize_price_data
      retail_price = product_hash[:retail_price].to_f if product_hash[:retail_price].present?
      sale_price = product_hash[:sale_price].to_f product_hash[:sale_price].present?
      price_currency = product_hash[:currency]&.to_sym

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
          @price_data[price[1]] = DotOne::Utils::CurrencyConverter.convert_to_all(options[:default_currency], price[0])
        end
      end

      # Figure out product image
      @image_data = []
      @image_data << product_hash[:image_url] if product_hash[:image_url].present?

      # Dump everything to product data
      @product_data[:prices] = @price_data
      @product_data[:images] = @image_data
    end

    private

    def determine_is_promotion(product_hash)
      retail_price = product_hash[:retail_price]
      sale_price = product_hash[:sale_price]
      return false if retail_price.blank? || sale_price.blank?

      retail_price = retail_price.to_f
      sale_price = sale_price.to_f
      retail_price > sale_price
    end

    def determine_inventory_status(_product_hash)
      'In Stock'
    end
  end
end
