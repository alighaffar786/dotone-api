module DotOne::ApiClient::ProductApi
  class BaseClient
    attr_accessor :related_offer, :id, :host, :username, :password

    def initialize(options = {})
      @id = options[:id]
      @related_offer = options[:related_offer]
      @host = options[:host].presence
      @username = options[:username].presence
      @password = options[:password].presence

      item_collection.offer = related_offer
    end

    def self.download_path
      path = Rails.root.join('tmp', 'products')
      FileUtils.mkdir_p(path) unless File.directory?(path)

      path
    end

    def item_collection
      @item_collection ||= DotOne::ApiClient::ProductApi::ItemCollection.new
    end

    def category_map
      @category_map ||= DotOne::ApiClient::ProductApi::GoogleCategoryMap.generate(locale: Language.platform_locale.upcase)
    end

    private

    def read_csv_entries
      return unless File.exist?(local_csv_file)

      CSV.foreach(
        local_csv_file,
        headers: true,
        header_converters: :symbol,
        quote_char: quote_chars.shift,
      ).with_index(1) do |row, index|
        yield row, index
      end

      File.delete(local_csv_file)
    end

    def local_csv_file
      download_path("#{id}.csv")
    end

    def quote_chars
      @quote_chars ||= ['"', '|', '~', '^', '&', '*']
    end

    def download_path(path)
      base_path = self.class.download_path.join(Date.today.to_s)
      FileUtils.mkdir_p(base_path) unless File.directory?(base_path)

      base_path.join(path).to_s
    end
  end
end
