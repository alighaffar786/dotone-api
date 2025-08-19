require 'net/ftp'
require 'nokogiri'

module DotOne::ApiClient::ProductApi::RakutenJp
  class Client < DotOne::ApiClient::ProductApi::RakutenGlobal::Client
    # A map of locale_string and its related
    # file bucket
    attr_accessor :file_bucket_hash

    def initialize(options = {})
      super(options)
      @data_format = 'txt'
      @file_bucket_hash = {}
    end

    def download
      if related_offer.linkshare_ftp_mid_sid.blank?
        locale_filename_setup = generate_filename_setup

        Net::FTP.open(@host) do |ftp|
          ftp.passive = true
          ftp.login(@username, @password)
          # Download all available locales
          locale_filename_setup.each_pair do |_locale_string, location|
            ftp.get(location[:remote_location], location[:local_location], 1024)
          end
        end

        locale_filename_setup.each_pair do |locale_string, location|
          IO.copy_stream(Zlib::GzipReader.open(location[:local_location]), uncompressed_file(related_offer, locale_string))
          # Cleanup file
          File.delete(location[:local_location])
        end

        locale_filename_setup.each_pair do |locale_string, _location|
          current_file = uncompressed_file(related_offer, locale_string)
          file_buckets = Array.new(4) { [] }
          splitter = DotOne::Utils::FileSplitter.new(current_file)
          splitter.splits(10_000) do |split_file, _index|
            file_buckets.rotate!.first << split_file
          end
          @file_bucket_hash[locale_string] = file_buckets
          File.delete(current_file)
        end
      end
      self
    end

    def to_items(options = {})
      threads = []

      @file_bucket_hash.each_pair do |locale_string, file_buckets|
        default_locale = 'EN-US'
        default_currency = 'USD'
        default_locale, default_currency = locale_string.split('_') unless locale_string == 'default'

        process_options = options.merge({
          locale_string: locale_string,
          default_currency: default_currency,
          related_offer: @related_offer,
        })

        file_buckets.each_with_index do |bucket, idx|
          threads << Thread.new do
            process_file_bucket(bucket, idx, process_options)
          end
        end
      end

      threads.each { |t| t.join }
    end

    def process_file_bucket(bucket, idx, options = {})
      bucket.each do |file|
        default_locale = 'EN-US'
        default_currency = 'USD'
        default_locale, default_currency = locale_string.split('_') unless options[:locale_string] == 'default'

        File.foreach(file).with_index do |line, index|
          product_line = line.split('|')
          next if product_line.length < 5

          DotOne::ApiClient::ProductApi::RakutenJp::Item.new(
            options[:client_api],
            product_line, {
              default_locale: default_locale,
              default_currency: default_currency,
              offer_id: related_offer.id,
            }
          )
        end

        item_collection.process(0, options.merge(flush: true))

        File.delete(file) if File.exist?(file)
      end
    end
  end
end
