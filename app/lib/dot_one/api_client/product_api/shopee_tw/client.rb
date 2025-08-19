require 'net/http'
require 'open-uri'

module DotOne::ApiClient::ProductApi::ShopeeTw
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    def download
      remote_csv_files.each do |remote_file|
        uri = URI(remote_file[:url])

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth remote_file[:username], remote_file[:password]

        http.request request do |response|
          open local_csv_file(remote_file[:name]), 'w' do |io|
            response.read_body do |chunk|
              # puts "Writing  #{chunk.length} bits ..."
              io.write chunk.bytes.pack('c*').force_encoding('UTF-8')
            end
          end
        end
      end
    end

    def to_items(options = {})
      remote_csv_files.each do |file|
        next unless File.exist?(local_csv_file(file[:name]))

        quote_chars = ['"', '|', '~', '^', '&', '*'] # "

        begin
          CSV.foreach(
            local_csv_file(file[:name]),
            headers: true,
            header_converters: :symbol,
            quote_char: quote_chars.shift,
          ).with_index(1) do |row, index|
            row_options = row.to_hash.merge(
              locale: Language.platform_locale.upcase,
              offer_id: related_offer.id,
            )

            item = DotOne::ApiClient::ProductApi::ShopeeTw::Item.new(options[:client_api], row_options)
            item_collection.push(item, options)
            item_collection.process(index, options)
          end

          item_collection.process(0, options.merge(flush: true))

          # Clean out file
          File.delete(local_csv_file(file[:name]))
        rescue CSV::MalformedCSVError
          quote_chars.empty? ? raise : retry
        end
      end
    end

    private

    def remote_csv_files
      [
        {
          name: 'mall1',
          username: 'nAlZLfx3MW1010',
          password: '0bIjjb98X4',
          url: 'https://mkt-proxy.shopee.tw/mkt/productfeeds/adminapi/fixed/download/XuhusyJMYs1010/1',
        },
        {
          name: 'mall2',
          username: 'nAlZLfx3MW1010',
          password: '0bIjjb98X4',
          url: 'https://mkt-proxy.shopee.tw/mkt/productfeeds/adminapi/fixed/download/XuhusyJMYs1010/2',
        },
        {
          name: 'non_mall1',
          username: 'E6vUAgDEaS1011',
          password: 'RHqkGwVHiQ',
          url: 'https://mkt-proxy.shopee.tw/mkt/productfeeds/adminapi/fixed/download/sr0xXEJzCO1011/1',
        },

        {
          name: 'non_mall2',
          username: 'E6vUAgDEaS1011',
          password: 'RHqkGwVHiQ',
          url: 'https://mkt-proxy.shopee.tw/mkt/productfeeds/adminapi/fixed/download/sr0xXEJzCO1011/2',
        },
      ]
    end

    def local_csv_file(key)
      download_path("shopee_tw_#{key}.csv")
    end
  end
end
