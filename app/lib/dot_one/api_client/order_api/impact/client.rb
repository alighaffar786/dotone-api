module DotOne::ApiClient::OrderApi::Impact
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 60
    MAX_DAYS = 45

    attr_accessor :start_at, :end_at, :api_key

    def initialize(options = {})
      super(options)
      @start_at = (Date.parse(options[:start_at]) rescue (Date.today - DAYS_TO_THE_PAST.day))
      @end_at = (Date.parse(options[:end_at]) rescue Date.today)
      @api_key = options[:key]
      @auth_token = options[:auth_token]
      @http_headers = {
        'Accept': 'application/json',
      }
      @missing_click_with_order_number = true
    end

    def request_url
      queries = {
        ActionDateStart: @start_at.to_time.utc.iso8601,
        ActionDateEnd: @end_at.to_time.end_of_day.utc.iso8601,
      }

      URI::HTTPS.build(
        host: 'api.impact.com',
        path: "/Mediapartners/#{api_key}/Actions",
        query: queries.to_param,
      )
    end


    def chunk_dates
      start_date = start_at
      result = []

      while start_date < Date.today
        end_date = start_date + MAX_DAYS.days
        end_date = Date.today if end_date > Date.today
        result << [start_date, end_date]
        start_date += (MAX_DAYS + 1).days
      end

      result
    end

    def to_items(options = {})
      records = chunk_dates.flat_map do |dates|
        @start_at, @end_at = dates

        to_json['Actions']
      end

      iterate_and_capture_missing_clicks(records) do |row|
        next if row['SubId2'].blank?

        item = DotOne::ApiClient::OrderApi::Impact::Item.new(row, client: self)
        item.log_it!
        @item_keys << store_it!(item, options)
      end

      @item_keys
    end
  end
end
