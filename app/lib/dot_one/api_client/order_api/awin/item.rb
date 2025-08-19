module DotOne::ApiClient::OrderApi::Awin
  ##
  # Class represents each of Awin's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record = {})
      super(record)
      @order_number = record['id']
      @click_stat = obtain_transaction(record.dig('clickRefs', 'clickRef'))
      @total = record.dig('saleAmount', 'amount')
      @true_pay = record.dig('commissionAmount', 'amount')

      return unless @click_stat.present?

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?
      @recorded_at = to_datetime(record['transactionDate'])
      @converted_at = use_own_converted_at
      @status = status_map(record['commissionStatus'])
    end

    private

    def status_map(status_string)
      case status_string.downcase
      when 'pending'
        Order.status_pending
      when 'approved'
        Order.status_approved
      when 'declined', 'deleted'
        Order.status_rejected
      end
    end

    def to_datetime(str)
      datetime = Time.strptime(str, DotOne::ApiClient::OrderApi::Awin::Client::DATE_FORMAT)
      TimeZone.current.from_utc(datetime)
    rescue StandardError
    end
  end
end
