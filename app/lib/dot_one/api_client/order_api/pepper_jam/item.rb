module DotOne::ApiClient::OrderApi::PepperJam
  ##
  # Class represents each of PepperJam's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record = {})
      super(record)
      @order_number = record['order_id']
      @click_stat = obtain_transaction(record['sid'])
      @total = record['sale_amount']
      @true_pay = record['commission']

      return unless @click_stat.present?

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?
      @recorded_at = TimeZone.current.from_utc(Time.parse(record['date'])) rescue use_own_captured_at
      @converted_at = use_own_converted_at
      @status = status_map(record['status'])
    end

    private

    def status_map(status_string)
      status_string = status_string.downcase
      if status_string == 'paid'
        Order.status_approved
      else
        Order.status_pending
      end
    end
  end
end
