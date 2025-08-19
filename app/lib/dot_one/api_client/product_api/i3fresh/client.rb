require 'open-uri'
require 'csv'

module DotOne::ApiClient::ProductApi::I3fresh
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def download
      open(local_csv_file, 'wb') do |file|
        file << URI.open(remote_csv_file).read
      end
    end

    def to_items(options = {})
      begin
        read_csv_entries do |row, index|
          # Add new or update product to database
          row_options = row.to_hash.merge({
            locale: Language.platform_locale.upcase,
            currency: Currency.platform_code,
            offer_id: related_offer.id,
          })

          item = DotOne::ApiClient::ProductApi::I3fresh::Item.new(options[:client_api], row_options)
          item_collection.push(item, options)
          item_collection.process(index, options)
        end

        item_collection.process(0, options.merge(flush: true))
      rescue CSV::MalformedCSVError
        quote_chars.empty? ? raise : retry
      end
    end

    private

    def remote_csv_file
      'https://i3fresh.tw/offer_support/product.php'
    end

    def local_csv_file
      download_path('i3fresh.csv')
    end
  end
end
