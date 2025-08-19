module DotOne::ApiClient::ProductApi::GoogleProduct
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    include DotOne::ApiClient::ProductApi::XmlFeedHelper

    def to_items(options = {})
      read_entries do |row, index|
        row_options = row.to_hash.merge(
          offer_id: related_offer.id,
          category_map: category_map,
        )
        item = DotOne::ApiClient::ProductApi::GoogleProduct::Item.new(options[:client_api], row_options)
        item_collection.push(item, options)
        item_collection.process(index, options)
      end

      item_collection.process(0, options.merge(flush: true))
    end

    private

    def headers
      [
        'id', 'title', 'description', 'brand', 'price', 'google_product_category',
        'link', 'image_link', 'condition', 'availability', 'sale_price',
        'additional_image_link', 'product_type'
      ]
    end

    def entry_name
      'item'
    end

    def local_xml_file
      download_path("google-product-#{id}.xml")
    end
  end
end
