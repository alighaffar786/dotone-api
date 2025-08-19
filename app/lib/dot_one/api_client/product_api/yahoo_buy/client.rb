# frozen_string_literal: true

require 'net/ftp'

module DotOne::ApiClient::ProductApi::YahooBuy
  class Client < DotOne::ApiClient::ProductApi::BaseClient
    attr_accessor :product_files, :categories

    def initialize(options = {})
      super(options)

      @host ||= 'asia-dropbox.yahoo.com'
      @username ||= 'ecsearch'
      @password ||= 'qJ42lx3c'

      @categories = {}
      @product_files = []
    end

    # Returns a hash of FTP options, including authentication credentials and SSL settings.
    def ftp_options
      {
        username: @username,
        password: @password,
        passive: true,
        ssl: {
          verify_mode: OpenSSL::SSL::VERIFY_NONE,
        },
      }
    end

    def download
      current_date_folder = date_folder(Date.today)

      Net::FTP.open(@host, ftp_options) do |ftp|
        use_yesterday = false

        begin
          ftp.chdir(current_date_folder)
        rescue Exception => e
          raise e unless e.message =~ /Failed to change directory/ && !use_yesterday

          use_yesterday = true
          current_date_folder = date_folder(Date.yesterday)
          retry
        end

        ftp.get('category.json.gz', local_category_file('json.gz'), 1024)

        gzip_product_files = ftp.nlst.grep(/^buy_.*\.json\.gz$/)

        gzip_product_files.each do |file|
          ftp.get(file, local_product_file(file), 1024)
        end

        # Extract categories
        extract_file(local_category_file('json.gz'))

        # Extract product files
        gzip_product_files.each do |file|
          extract_file(local_product_file(file))
        end

        @product_files = gzip_product_files.map { |f| f.sub('.gz', '') }
      end

      self
    end

    def parse_categories
      lines = File.read(local_category_file('json'))
      json = JSON.parse(lines) rescue {}
      if json['response_data']
        extract_name_map(json['response_data'])
        @categories = @categories.with_indifferent_access
      end
      nil
    end

    def to_items(options = {})
      parse_categories
      process_options = options.merge(related_offer: @related_offer, categories: @categories)

      threads = []
      slice = (product_files.size / 4.0).ceil
      idx = 0
      product_files.each_slice(slice) do |bucket|
        threads << Thread.new do
          process_file_bucket(bucket, idx, process_options)
        end

        idx += 1
      end

      threads.each(&:join)

      File.delete(local_category_file('json'))
    end

    def process_file_bucket(bucket, idx, options = {})
      bucket.each do |file_name|
        file = local_product_file(file_name)
        next unless File.exist?(file)

        json_content = []

        File.foreach(file) do |line|
          json_content << JSON.parse(line)
        end

        collection_options = options.merge({ bucket_index: idx, batch_size: 20_000 })

        json_content.each_with_index do |j, index|
          row_options = j.to_hash.merge({ offer_id: related_offer.id })
          item_options = {
            category_map: options[:categories],
          }

          item = DotOne::ApiClient::ProductApi::YahooBuy::Item.new(
            options[:client_api],
            row_options,
            item_options,
          )

          item_collection.push(item, collection_options)
          item_collection.process(index, collection_options)
        end

        item_collection.process(0, options.merge(flush: true))

        File.delete(file)
      end
    end

    def extract_file(source)
      Zlib::GzipReader.open(source) do |gz|
        File.write(source.sub('.gz', ''), gz.read)
      end

      File.delete(source)
    end

    private

    # Recursively transverse hash
    # all the way down, collecting all the names
    # of categories and put it in a flat category hash
    def extract_name_map(hash)
      keys = hash.keys
      if keys.include?('name') && keys.include?('cat_id')
        if hash['name'].present? && hash['cat_id'].present?
          @categories[hash['cat_id']] = hash['name']
        end
      else
        keys.each do |k|
          extract_name_map(hash[k]) if hash[k].is_a?(Hash)
        end
      end
    end

    def local_product_file(file)
      "#{Rails.root}/tmp/yahoo-buy-#{file}"
    end

    def local_category_file(ext)
      "#{Rails.root}/tmp/yahoo-buy-categories.#{ext}"
    end

    # Helper to determine the folder to access
    # on remote server
    def date_folder(timeframe)
      "buy/ecitem/full/#{timeframe.strftime('%Y%m%d')}01/"
    end

  end
end
