# Sample URL
# https://VGfcXR31Pj:E46oqVB9@api.performancehorizon.com/reporting/report_publisher/publisher/1101l11995/conversion.json?start_date=2017-01-31+00%3A00%3A00&end_date=2017-02-01+00%3A00%3A00&currency=USD

module DotOne::ApiClient::OrderApi::Partnerize
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 90

    attr_accessor :start_at, :end_at, :api_key, :api_affiliate_id, :offset

    def initialize(options = {})
      super(options)
      @start_at = Date.parse(options[:start_at]) rescue Date.today - DAYS_TO_THE_PAST.day
      @start_at = "#{@start_at} 00:00:00"

      @end_at = Date.parse(options[:end_at]) rescue Date.today
      @end_at = "#{@end_at} 23:59:59"

      @api_key = options[:key]
      @api_affiliate_id = options[:api_affiliate_id]
      @auth_token = options[:auth_token]
      @offset = options[:offset] || 0
    end

    def request_url
      queries = {
        start_date: @start_at,
        end_date: @end_at,
        token: @api_key,
        limit: 300,
        offset: @offset,
        ref_conversion_metric_id: [2, 12, 31],
        timezone: 'GMT',
      }

      URI::HTTPS.build({
        host: 'api.partnerize.com',
        path: "/reporting/report_publisher/publisher/#{@api_affiliate_id}/conversion.json",
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
      while json_response['conversions'].is_a?(Array) && json_response['conversions'].length > 0
        records = flatten_records(json_response['conversions'].map { |record| record['conversion_data'] })

        iterate_and_capture_missing_clicks(records) do |record|
          item = DotOne::ApiClient::OrderApi::Partnerize::Item.new(record, options)

          item.log_it!
          custom_cache_key = [record['conversion_item_id']]

          @item_keys << store_it!(item, options.merge(custom_cache_key: custom_cache_key))
        end

        self.offset = json_response['offset'] + json_response['limit']
        json_response = to_json
      end

      @item_keys.uniq
    end

    private

    def flatten_records(records)
      expand_record = proc do |record, item|
        record['sku'] = item['sku'].to_s
        record['item_publisher_commission'] = item['item_publisher_commission'].to_f
        record['item_value'] = item['item_value'].to_f
        record['item_status'] = item['item_status']
        record['conversion_item_id'] = item['conversion_item_id']
        record.clone
      end

      records.flat_map do |record|
        items = record['conversion_items']

        if items.present?
          items.map do |item|
            expand_record.call(record, item)
          end
        else
          expand_record.call(record, {})
        end
      end
    end
  end
end
