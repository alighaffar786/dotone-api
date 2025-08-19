require 'open-uri'
require 'zip'
require 'csv'

module DotOne::ApiClient::ProductApi::Kkday
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    AVAILABLE_LOCALES = {
      'zh-tw': ['ZH-TW', 'USD'],
      'zh-cn': ['ZH-CN', 'USD'],
      en: ['EN-US', 'USD'],
      ja: ['JA-JP', 'USD'],
      ko: ['KO-KR', 'USD'],
    }

    def download
      AVAILABLE_LOCALES.each_key do |locale|
        File.binwrite(local_zip_file(locale), URI.open(remote_zip_file(locale)).read)

        FileUtils.rm_f(local_csv_file(locale))

        Zip::File.open(local_zip_file(locale)) do |zip_file|
          entry = zip_file.glob('*.csv').first
          entry.extract(local_csv_file(locale))
        end

        File.delete(local_zip_file(locale))
      end
    end

    def to_items(options = {})
      AVAILABLE_LOCALES.each_key do |locale|
        quote_chars = ['"', '|', '~', '^', '&', '*']

        begin
          ::CSV.foreach(
            local_csv_file(locale),
            headers: true,
            header_converters: :symbol,
            quote_char: quote_chars.shift,
          ).with_index(1) do |row, index|
            # Add new or update product to database
            row_options = row.to_hash.merge({
              locale: AVAILABLE_LOCALES[locale][0],
              currency: AVAILABLE_LOCALES[locale][1],
              offer_id: related_offer.id,
            })

            item_collection.push(DotOne::ApiClient::ProductApi::Kkday::Item.new(options[:client_api], row_options), options)
            item_collection.process(index, options)
          end

          item_collection.process(0, options.merge(flush: true))

          # Clean out file
          File.delete(local_csv_file(locale))
        rescue CSV::MalformedCSVError => e
          quote_chars.empty? ? raise(e) : retry
        end
      end
    end

    private

    def remote_zip_file(locale)
      "http://s1.kkday.com/productSnap/products_#{locale}.zip"
    end

    def local_csv_file(locale)
      download_path("kkday-#{locale}.csv")
    end

    def local_zip_file(locale)
      download_path("kkday-#{locale}.zip")
    end
  end
end
