module DotOne::ApiClient::OrderApi::I3fresh
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 90

    attr_accessor :start_at, :end_at

    def initialize(options = {})
      super(options)
      @start_at = Date.parse(options[:start_at]).to_s rescue nil
      @start_at = (Date.today - DAYS_TO_THE_PAST.day).to_s if @start_at.blank?

      @end_at = Date.parse(options[:end_at]).to_s rescue nil
      @end_at = Date.today.to_s if @end_at.blank?
      @missing_click_with_order_number = true
    end

    def request_url
      queries = {
        date_start: @start_at,
        date_end: @end_at,
      }

      URI::HTTPS.build({
        host: 'i3fresh.tw',
        path: '/affiliates_get_data.php',
        query: queries.to_param,
      })
    end

    ##
    # Method to convert response to items:
    # Each conversion_items on JSON response
    # will be mapped into its own item hence order.
    def to_items
      json_response = to_json

      iterate_and_capture_missing_clicks(json_response) do |record|
        item = DotOne::ApiClient::OrderApi::I3fresh::Item.new(record)
        item.log_it!
        @item_keys << store_it!(item)
      end

      @item_keys
    end
  end
end
