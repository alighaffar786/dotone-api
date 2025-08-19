module DotOne::ApiClient::OrderApi::Clickwise
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 90

    attr_accessor :start_at, :end_at, :api_key, :page

    def initialize(options = {})
      super(options)
      @start_at = Date.parse(options[:start_at]).to_s rescue nil
      @start_at = (Date.today - DAYS_TO_THE_PAST.day).to_s if @start_at.blank?

      @end_at = Date.parse(options[:end_at]).to_s rescue nil
      @end_at = Date.today.to_s if @end_at.blank?

      @api_key = options[:key]

      @page = options[:page] || 0
      @missing_click_with_order_number = true
    end

    def request_url
      @http_method = :put

      @http_headers = {}
      @http_headers['X-ApiKey'] = @api_key

      queries = {
        from: @start_at,
        to: @end_at,
        limit: 1000,
        page: @page,
      }

      URI::HTTPS.build({
        host: 'api.clickwise.net',
        path: '/transactions',
        query: queries.to_param,
      })
    end

    ##
    # Method to convert response to items:
    # Each conversion_items on JSON response
    # will be mapped into its own item hence order.
    def to_items
      self.page = 0
      json_response = to_json

      # Take of pagination from Clickwise API
      transactions = json_response['transactions'].to_a

      while transactions.length > 0
        iterate_and_capture_missing_clicks(transactions) do |record|
          next if record['sid1'].blank?

          item = DotOne::ApiClient::OrderApi::Clickwise::Item.new(record)
          item.log_it!
          @item_keys << store_it!(item)
        end

        self.page += 1
        json_response = to_json
        transactions = json_response['transactions']
      end

      @item_keys
    end
  end
end
