require 'open-uri'

module DotOne::ApiClient::ProductApi::Dokodemo
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def download
      CSV.open(local_csv_file, 'wb') do |csv|
        csv << headers
        entries.each do |entry|
          csv << headers.map { |header| entry[header] }
        end
      end

      local_csv_file
    end

    def to_items(options = {})
      begin
        read_csv_entries do |row, index|
          row_options = row.to_hash.merge(
            locale: Language.platform_locale.upcase,
            offer_id: related_offer.id,
            category_map: category_map,
          )
          item = DotOne::ApiClient::ProductApi::Dokodemo::Item.new(options[:client_api], row_options)
          item_collection.push(item, options)
          item_collection.process(index, options)
        end

        item_collection.process(0, options.merge(flush: true))
      rescue CSV::MalformedCSVError
        quote_chars.empty? ? raise : retry
      end
    end

    private

    def response
      @response ||= begin
        URI.open(host).read.force_encoding('UTF-8')
      rescue StandardError
        Rails.logger.error 'Invalid host!'
      end
    end

    def entries
      @entries ||= begin
        csv = CSV.new(response, {
          headers: true,
          col_sep: "\t",
          quote_char: "\x00",
        })
        csv.entries
      rescue StandardError
        []
      end
    end

    def headers
      [
        'id', 'title', 'description', 'link', 'image_link', 'brand', 'condition', 'availability', 'price', 'sale_price', 'google_product_category'
      ]
    end

    def local_csv_file
      download_path("dokodemo-#{id}.csv")
    end
  end
end
