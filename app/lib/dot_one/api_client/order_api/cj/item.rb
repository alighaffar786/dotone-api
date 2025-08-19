module DotOne::ApiClient::OrderApi::Cj
  ##
  # Class represents each of CJ's order item.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record, options = {})
      super(record)
      @click_stat = obtain_transaction(record['shopperId'])
      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?

      @order_number_only = record['orderId']
      @order_number_with_sku = record['orderIdWithSku']
      @order_number = order_number_to_record

      @order_number_with_unique_string = add_commission_id_to_order_number(record['commissionId'])

      # Update order number to add commission ID from CJ to guarantee
      # uniqueness as new order number format for CJ.
      # TODO: Remove these block of codes after 1 year from now (2022-04-28) since most
      # pending orders might already use the new order number format
      current_order = order
      if current_order.present? && !current_order.order_number.include?('::')
        current_order.update(order_number: @order_number_with_unique_string)
      end
      # End to Remove

      @order_number = @order_number_with_unique_string

      @total = if record['totalSaleAmountUsd'].present?
        record['totalSaleAmountUsd'].to_f
      else
        record['saleAmountUsd'].to_f
      end

      # 2022-10-08: Commented out this line since 0.0 is a valid commission
      # @true_pay = if record['totalCommissionUsd'].present? && record['totalCommissionUsd'].to_f != 0.0
      @true_pay = if record['totalCommissionUsd'].to_f == 0
        record['pubCommissionAmountUsd'].to_f
      else
        record['totalCommissionUsd'].to_f
      end

      # if we are paying CPL to affiliate, no commission from advertiser
      # means no payment to affiliate
      @affiliate_pay = 0.0 if @true_pay == 0.0 && copy_stat && copy_stat.affiliate_conv_type == 'CPL'

      @status = status_map(record)
      @recorded_at = TimeZone.current.from_utc(parse_date_string(record['postingDate']))

      # For CJ, negative amount is approved to reflect
      # the correct amount for each order. CJ reflects
      # returns as closed/approved negative payouts
      self.on_negative_margin = :approve
    end

    private

    def add_commission_id_to_order_number(commission_id)
      return if @order_number.blank?
      return @order_number if commission_id.blank?

      [@order_number, commission_id].join('::')
    end

    def status_map(options)
      commission = options['totalCommissionUsd'] || options['pubCommissionAmountUsd']
      commission = commission.to_f

      # No rejects. CJ will put negative commission
      # when an order is returned so it
      # will be Approved to offset the original order
      if ['closed', 'locked'].include? options['actionStatus']
        Order.status_approved
      else
        Order.status_pending
      end
    end

    def parse_date_string(str)
      return if str.blank?

      Time.strptime(str, DotOne::ApiClient::OrderApi::Cj::Client::DATE_FORMAT)
    end
  end
end
