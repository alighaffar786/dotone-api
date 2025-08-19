module DotOne::ApiClient::OrderApi::I3fresh
  ##
  # Class represents each of I3fresh's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record = {}, _options = {})
      super(record)
      @order_number = record['order']
      @click_stat = obtain_transaction(record['server_subid'])
      @total = record['order_total']

      return unless @click_stat.present?

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?
      @recorded_at = use_own_captured_at
      @converted_at = use_own_converted_at
      @status = status_map(record['status'])
    end

    private

    def status_map(status_string)
      status_string = status_string.downcase
      if status_string == 'return'
        Order.status_rejected
      elsif status_string == 'confirm'
        Order.status_approved
      else
        Order.status_pending
      end
    end
  end
end
