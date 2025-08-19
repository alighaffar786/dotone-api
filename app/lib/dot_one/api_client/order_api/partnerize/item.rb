module DotOne::ApiClient::OrderApi::Partnerize
  ##
  # Class represents each of Performance Horizon's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record, options = {})
      super(record)
      @click_stat = obtain_transaction(record['publisher_reference'])
      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?

      @recorded_at = TimeZone.current.from_utc(record['conversion_time'], format: '%Y-%m-%d %H:%M:%S')

      @converted_at = use_own_converted_at

      @order_number_only = record['conversion_reference']
      @order_number_with_unique_string = "#{record['conversion_reference']}:#{record['sku']}::#{record['conversion_item_id']}"
      @order_number = order_number_to_record

      current_order = order
      if current_order.present? && !current_order.order_number.include?('::')
        current_order.update(order_number: @order_number_with_unique_string)
      end

      @order_number = @order_number_with_unique_string

      @total = record['item_value']
      @true_pay = record['item_publisher_commission']
      @status = status_map(record['item_status'])
    end

    private

    ##
    # Determine the status of this item.
    # Since we don't record conversion for each item,
    # we will reflect the summary of all item status.
    # Order is pending if at least one item is pending.
    # Order is approved if at least one item is approved and no pending.
    # Order is rejected if all items are rejected.
    # For pending and approved orders, order total and payout
    # will be adjusted.
    # For rejected orders, order total and payout will show
    # total amount derived from the items
    def status_map(status)
      case status
      when 'pending'
        Order.status_pending
      when 'approved'
        Order.status_approved
      else
        Order.status_rejected
      end
    end
  end
end
