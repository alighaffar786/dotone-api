module DotOne::ApiClient::OrderApi::Awin
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 180
    DATE_FORMAT = '%FT%T'
    MAX_DATE_RANGE = 31

    attr_accessor :start_at, :end_at, :current_start_at, :current_end_at, :access_token, :api_affiliate_id

    def initialize(options = {})
      super(options)
      @start_at = Date.parse(options[:start_at]) rescue (Date.today - DAYS_TO_THE_PAST.day)
      @end_at = Date.parse(options[:end_at]) rescue (Date.today - 1.day)
      @access_token = options[:auth_token]
      @api_affiliate_id = options[:api_affiliate_id]
      @missing_click_with_order_number = true
    end

    def current_start_at=(value)
      @current_start_at = if value && value > end_at
        end_at
      else
        value
      end
    end

    def current_end_at=(value)
      @current_end_at = if value && value > end_at
        end_at
      else
        value
      end
    end

    def request_url
      queries = {
        startDate: current_start_at.beginning_of_day.strftime(DATE_FORMAT),
        endDate: current_end_at.end_of_day.strftime(DATE_FORMAT),
        timezone: 'UTC',
        dateType: 'validation',
        accessToken: access_token,
      }

      URI::HTTPS.build(
        host: 'api.awin.com',
        path: "/publishers/#{api_affiliate_id}/transactions/",
        query: queries.to_param,
      )
    end

    def to_json(*_args)
      return @to_json if @to_json.present?

      @to_json = []

      while current_end_at != end_at
        self.current_start_at = current_end_at + 1.day rescue start_at
        self.current_end_at = current_start_at + MAX_DATE_RANGE.days
        json_response = super

        raise json_response['description'] if json_response.is_a?(Hash) && json_response['error'].present?
        raise json_response if json_response.is_a?(Hash)

        @to_json += json_response
      end

      @to_json
    end

    ##
    # Method to convert response to items:
    # Each conversion_items on JSON response
    # will be mapped into its own item hence order.
    def to_items(options = {})
      json_response = to_json

      # Due to pagination on AWIN part,
      # while loop will go through all the pages and collect
      # all the orders before returning the result.
      iterate_and_capture_missing_clicks(json_response) do |record|
        item = DotOne::ApiClient::OrderApi::Awin::Item.new(record)
        item.log_it!
        @item_keys << store_it!(item, options)
      end

      @item_keys
    end
  end
end
