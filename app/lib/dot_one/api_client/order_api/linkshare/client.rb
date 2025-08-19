module DotOne::ApiClient::OrderApi::Linkshare
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 120

    attr_accessor :start_at, :end_at, :api_key

    def initialize(options = {})
      super(options)
      @start_at = (Date.parse(options[:start_at]) rescue (Date.today - DAYS_TO_THE_PAST.day)).to_s
      @end_at = (Date.parse(options[:end_at]) rescue Date.today).to_s

      @api_key = options[:key]
    end

    def request_url
      queries = {
        start_date: @start_at,
        end_date: @end_at,
        token: @api_key,
      }

      URI::HTTPS.build({
        host: 'ran-reporting.rakutenmarketing.com',
        path: '/en/reports/signature-orders-report/filters',
        query: queries.to_param,
      })
    end

    ##
    # Routine to clean up csv response before import.
    def sanitized_csv_response
      # Clean up the extra headers
      response_array = response.split(/\r\n\r\n/)
      response_array&.last&.strip
    end

    # Method to convert response to items
    def to_items(options = {})
      console = options[:console] || false

      records = CSV.parse(sanitized_csv_response, headers: true, skip_blanks: true)

      iterate_and_capture_missing_clicks(records) do |row|
        next if row['Member ID (U1)'].blank?

        item = DotOne::ApiClient::OrderApi::Linkshare::Item.new(row, client: self)
        item.log_it!
        @item_keys << store_it!(item, options)
      end

      @item_keys
    end
  end
end
