module DotOne::ApiClient::OrderApi::Clickwise
  ##
  # Class represents each of Clickwise's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record = {})
      super(record)
      @order_number = record['orderid']
      @click_stat = obtain_transaction(record['sid1'])
      @total = record['totalcost']
      @true_pay = record['affcommission'].presence || 0
      @status = status_map(record['status'])

      return unless @click_stat.present?

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?
      @order = @click_stat.orders.where(order_number: @order_number).first

      # At the time of this writing,
      # Clickwise API has unclear timezone on the timestamp
      # for order creation time (under record['created']).
      # Thus, we just determine the captured time ourselves.
      @recorded_at = use_own_captured_at
      @converted_at = use_own_converted_at
    end

    private

    def status_map(status_string)
      status_string = status_string.downcase
      if status_string == 'd'
        Order.status_rejected
      elsif status_string == 'a'
        Order.status_approved
      else
        Order.status_pending
      end
    end
  end
end
