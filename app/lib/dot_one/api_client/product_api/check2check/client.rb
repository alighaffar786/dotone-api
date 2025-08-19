require 'net/http'
require 'openssl'
require 'open-uri'
require 'csv'

module DotOne::ApiClient::ProductApi::Check2check
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def download
      uri = URI(remote_csv_file)
      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == 'https',
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
      ) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        request.basic_auth 'dpa_check', '6hvF<8-$mPz%#Lvj'

        http.request request do |response|
          open local_csv_file, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk.encode('UTF-8', 'filesystem')
            end
          end
        end
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

          item_collection.push(
            DotOne::ApiClient::ProductApi::Check2check::Item.new(options[:client_api], row_options), options
          )
          item_collection.process(index, options)
        end

        item_collection.process(0, options.merge(flush: true))
      rescue CSV::MalformedCSVError
        quote_chars.empty? ? raise : retry
      end
    end

    private

    def remote_csv_file
      'https://connect.mallbic.com/API/ThirdParty/FacebookDynamicProduct.ashx?shopkey=66148555'
    end

    def local_csv_file
      download_path('check2check.csv')
    end
  end
end
