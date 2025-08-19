require 'csv'

module DotOne::ApiClient::ProductApi::Csv
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def to_items(options = {})
      read_csv_entries do |row, index|
        row_options = row.merge(
          locale: Language.platform_locale.upcase,
          offer_id: related_offer.id,
          category_map: category_map,
        )
        item = DotOne::ApiClient::ProductApi::Csv::Item.new(options[:client_api], row_options)
        item_collection.push(item, options)
        item_collection.process(index, options)
      end

      item_collection.process(0, options.merge(flush: true))
    end

    def download
      Net::HTTP.get_response(URI(host)) do |response|
        File.open(local_csv_file, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end
      end
    end

    private

    def read_csv_entries
      return unless File.exist?(local_csv_file)

      CSV.foreach(
        local_csv_file,
        headers: true,
        header_converters: :symbol,
        quote_char: quote_chars.shift,
      ).with_index(1) do |item, index|
        row = headers.map { |header| [header, item[header]] }.to_h

        yield row, index
      end

      File.delete(local_csv_file)
    rescue CSV::MalformedCSVError
      quote_chars.empty? ? raise : retry
    end

    def headers
      [
        :id, :title, :description, :link, :image_link, :brand, :condition,
        :availability, :price, :sale_price, :google_product_category, :product_type,
      ]
    end
  end
end
