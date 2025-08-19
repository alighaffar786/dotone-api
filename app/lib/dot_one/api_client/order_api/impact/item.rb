module DotOne::ApiClient::OrderApi::Impact
  class Item < DotOne::ApiClient::OrderApi::BaseItem
    attr_accessor :order_number_only, :order_number_with_sku

    def initialize(record = {}, _options = {})
      super(record)
      @order_number = record['Id']
      @click_stat = obtain_transaction(record['SubId2'])

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?

      @recorded_at = record['ReferringDate']
      @status = retrieve_status

      @total = record['Amount']
      @true_pay = record['Payout']
    end

    private

    def retrieve_status
      case record['State']
      when 'APPROVED'
        Order.status_approved
      when 'REVERSED'
        Order.status_rejected
      else
        Order.status_pending
      end
    end
  end
end
