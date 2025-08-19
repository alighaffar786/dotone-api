require 'net/ftp'
require 'nokogiri'

module DotOne::ApiClient::ProductApi::RakutenGlobal
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    ##
    # Each relateed offer need to specify
    # the following on its Hash key-values:
    #
    # key: linkshare_ftp_mid_sid
    #   This is to indicate unique id to the file
    #
    # key: linkshare_ftp_available_locales
    #   This is to specify all the available locales.
    #   Please check FTP access to find them.

    # Flag to tell this API client
    # to just download the whole data
    # instead of just the delta/updates
    attr_accessor :download_all_data

    # Determine the available data format
    # on remote server
    attr_accessor :data_format

    def initialize(options = {})
      super(options)
      @download_all_data = options[:download_all_data] || false
      @data_format = 'xml'
    end

    def download
      if related_offer.linkshare_ftp_mid_sid.present?
        locale_filename_setup = generate_filename_setup

        Net::FTP.open(@host) do |ftp|
          ftp.passive = true
          ftp.login(@username, @password)
          # Download all available locales
          locale_filename_setup.each_pair do |_locale_string, location|
            ftp.get(location[:remote_location], location[:local_location], 1024)
          rescue Net::FTPPermError => e
            # Skip if file not found
          end
        end

        locale_filename_setup.each_pair do |locale_string, location|
          IO.copy_stream(Zlib::GzipReader.open(location[:local_location]), uncompressed_file(related_offer, locale_string))
          # Cleanup file
          File.delete(location[:local_location])
        rescue Zlib::GzipFile::Error => e
          # Skip if file not able to uncompress
        end
      end
      self
    end

    def to_items(options = {})
      locale_filename_setup = generate_filename_setup

      locale_filename_setup.each_pair do |locale_string, _location|
        default_locale, default_currency = locale_string.split('_')
        if locale_string == 'default'
          default_locale = 'EN-US'
          default_currency = 'USD'
        end

        xml_file = uncompressed_file(related_offer, locale_string)

        index = 0

        next unless File.exist?(xml_file)

        Nokogiri::XML::Reader(File.open(xml_file)).each do |node|
          next unless node.name == 'product' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

          product_node = Nokogiri::XML(node.outer_xml).at('./product')
          item = DotOne::ApiClient::ProductApi::RakutenGlobal::Item.new(options[:client_api], product_node, {
            default_locale: default_locale,
            default_currency: default_currency,
            offer_id: related_offer.id,
          })
          next unless item.product_data[:client_id_value].present?

          item_collection.push(item, options)
          item_collection.process(index, options)
          index += 1
        end

        item_collection.process(0, options.merge(flush: true))

        # Cleanup file
        File.delete(uncompressed_file(related_offer, locale_string))
      end
    end

    def delta_string
      @download_all_data ? nil : '_delta'
    end

    def uncompressed_file(offer, locale = 'default')
      locale_string = locale == 'default' ? nil : locale
      locale_suffix = locale == 'default' ? nil : "_#{locale_string}"
      uncompressed_filename = [
        offer.linkshare_ftp_mid_sid,
        '_mp',
        delta_string,
        locale_suffix,
        ".#{@data_format}",
      ].join
      "#{Rails.root}/tmp/#{uncompressed_filename}"
    end

    def generate_filename_setup
      filename_setup = {}
      filename_setup['default'] = {
        remote_location: [related_offer.linkshare_ftp_mid_sid, '_mp', delta_string, ".#{@data_format}.gz"].join,
        local_location: "#{Rails.root}/tmp/#{[related_offer.linkshare_ftp_mid_sid, '_mp', delta_string,
          ".#{@data_format}.gz"].join}",
      }

      available_locales = related_offer.linkshare_ftp_available_locales.split(',') rescue []

      available_locales.each do |locale_string|
        locale_string.strip!
        remote_folder = locale_string
        remote_path = ['GLOBAL', remote_folder, ''].join('/')
        locale_suffix = "_#{locale_string}"
        filename_setup[locale_string] = {
          remote_location: "#{remote_path}#{related_offer.linkshare_ftp_mid_sid}_mp#{delta_string}#{locale_suffix}.#{@data_format}.gz",
          local_location: "#{Rails.root}/tmp/#{related_offer.linkshare_ftp_mid_sid}_mp#{delta_string}#{locale_suffix}.#{@data_format}.gz",
        }
      end
      filename_setup
    end
  end
end
