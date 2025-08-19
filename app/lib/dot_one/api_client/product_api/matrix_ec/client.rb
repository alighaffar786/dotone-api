module DotOne::ApiClient::ProductApi::MatrixEC
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    include DotOne::ApiClient::ProductApi::XmlFeedHelper

    def to_items(options = {})
      read_entries do |row, index|
        row_options = row.to_hash.merge(offer_id: related_offer.id)
        item = DotOne::ApiClient::ProductApi::MatrixEC::Item.new(
          options[:client_api], row_options
        )
        item_collection.push(item, options)
        item_collection.process(index, options)
      end

      item_collection.process(0, options.merge(flush: true))
    end

    private

    def headers
      [
        'id', 'availability', 'condition', 'description', 'image_link', 'link', 'title', 'price', 'brand', 'color', 'size', 'sale_price', 'google_product_category'
      ]
    end

    def entry_name
      'entry'
    end

    def local_xml_file
      download_path("matrix-ec-#{id}.xml")
    end
  end
end
