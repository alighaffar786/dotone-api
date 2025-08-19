module DotOne::ApiClient::OrderApi::PepperJam
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 90

    attr_accessor :start_at, :end_at, :api_key, :page

    def initialize(options = {})
      super(options)
      @start_at = (Date.parse(options[:start_at]) rescue Date.today - DAYS_TO_THE_PAST.day).to_s
      @end_at = (Date.parse(options[:end_at]) rescue Date.today - 1.day).to_s

      @api_key = options[:key]
      @page = options[:page] || 1
      @missing_click_with_order_number = true
    end

    def request_url
      queries = {
        startDate: @start_at,
        endDate: @end_at,
        apiKey: @api_key,
        format: 'json',
        page: @page,
      }

      URI::HTTPS.build({
        host: 'api.pepperjamnetwork.com',
        path: '/20120402/publisher/report/transaction-details',
        query: queries.to_param,
      })
    end

    ##
    # Method to convert response to items:
    # Each conversion_items on JSON response
    # will be mapped into its own item hence order.
    def to_items(options = {})
      json_response = to_json
      raise json_response['error']['message'] if json_response['error'].present?

      # Due to pagination on Performance Horizon part,
      # while loop will go through all the pages and collect
      # all the orders before returning the result.
      while json_response['data'].length > 0
        iterate_and_capture_missing_clicks(json_response['data']) do |record|
          item = DotOne::ApiClient::OrderApi::PepperJam::Item.new(record)
          item.log_it!
          @item_keys << store_it!(item, options)
        end
        self.page += 1
        json_response = to_json
      end

      @item_keys
    end
  end
end
