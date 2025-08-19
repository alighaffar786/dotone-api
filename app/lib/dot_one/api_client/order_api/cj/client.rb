module DotOne::ApiClient::OrderApi::Cj
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 180
    DATE_FORMAT = '%FT%TZ'
    MAX_DATE_RANGE = 31

    attr_accessor :start_at, :end_at, :api_key, :api_affiliate_id, :page, :order_map, :commission_ids_to_finalize

    def initialize(options = {})
      super(options)
      @start_at = Date.parse(options[:start_at]) rescue (Date.today - DAYS_TO_THE_PAST.day)
      @end_at = Date.parse(options[:end_at]) rescue Date.today

      @api_key = options[:key]
      @api_affiliate_id = options[:api_affiliate_id]

      @page = options[:page]
    end

    def current_start_at
      @current_start_at ||= start_at
    end

    def current_start_at=(value)
      @current_start_at = if value && value > end_at
        end_at
      else
        value
      end
    end

    def current_end_at
      @current_end_at ||= calculate_current_end_at
    end

    def current_end_at=(value)
      @current_end_at = if value && value > end_at
        end_at
      else
        value
      end
    end

    def http_body
      start_at_str = current_start_at.strftime(DATE_FORMAT)
      end_at_str = current_end_at.end_of_day.strftime(DATE_FORMAT)

      queries = [
        "forPublishers: [\"#{api_affiliate_id}\"]",
        "sincePostingDate: \"#{start_at_str}\"",
        "beforePostingDate: \"#{end_at_str}\"",
      ]

      queries << "sinceCommissionId: \"#{page}\"" if page.present?

      "{ publisherCommissions(#{queries.join(', ')}) {
          count payloadComplete maxCommissionId records {
            shopperId orderId commissionId actionStatus saleAmountUsd pubCommissionAmountUsd postingDate items {
              sku totalCommissionUsd perItemSaleAmountUsd quantity commissionItemId
            }
          }
        }
      }"
    end

    def request_url
      @http_method = :post

      @http_headers = {}
      @http_headers['Authorization'] = "Bearer #{@api_key}"

      URI::HTTPS.build({
        host: 'commissions.api.cj.com',
        path: '/query',
      })
    end

    def to_items(completed = false, options = {})
      return @item_keys if completed

      json_response = to_json

      self.page = json_response.dig('data', 'publisherCommissions', 'maxCommissionId')
      completed = json_response.dig('data', 'publisherCommissions', 'payloadComplete') || true
      raw_records = json_response.dig('data', 'publisherCommissions', 'records') || []
      records = flatten_records(raw_records)

      iterate_and_capture_missing_clicks(records) do |record|
        to_be_finalized = @commission_ids_to_finalize&.include?(record['commissionId']) && record['actionStatus'] == 'closed'

        if finalize && to_be_finalized || !finalize
          current_item = DotOne::ApiClient::OrderApi::Cj::Item.new(record, options)
          current_item.finalize = true if finalize && to_be_finalized

          current_item.log_it!
          @item_keys << store_it!(current_item)
        end
      end

      if completed
        if current_end_at == end_at
          self.current_start_at = self.current_end_at = nil
        else
          completed = false
          self.current_start_at = current_end_at + 1
          self.current_end_at = calculate_current_end_at
        end
      end

      to_items(completed, options)
    end

    private

    def calculate_current_end_at
      current_start_at + MAX_DATE_RANGE
    end

    def flatten_records(records)
      expand_record = proc do |record, item|
        quantity = item['quantity'].present? ? item['quantity'].to_i : nil

        if item['sku'].present? && item['perItemSaleAmountUsd'].present? && quantity.present?
          total_sale_amount = item['perItemSaleAmountUsd'].to_f * quantity
        end

        order_id_with_sku = nil

        if item['sku'].present? && record['orderId'].present?
          order_id_with_sku = [record['orderId'], item['sku']].join(':')
        elsif record['orderId'].present?
          order_id_with_sku = record['orderId']
        end

        record['orderIdWithSku'] = order_id_with_sku
        record['totalSaleAmountUsd'] = total_sale_amount

        totalCommissionUsd = item['totalCommissionUsd'].present? ? item['totalCommissionUsd'].to_f : nil

        record['totalCommissionUsd'] = totalCommissionUsd

        if totalCommissionUsd.present? && totalCommissionUsd > 0.0 && quantity.present? && quantity < 0
          record['totalCommissionUsd'] = totalCommissionUsd * -1
        end

        record.clone
      end

      records.flat_map do |record|
        items = record['items']

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
