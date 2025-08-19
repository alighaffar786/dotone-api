module DotOne::ApiClient::OrderApi::Linkshare
  ##
  # Class represents each of Linkshare's order item as
  # extracted from Linkshare Report API.
  #
  # Notes:
  #
  # 1. Default status will be Pending since Linkshare
  # policy allows its advertisers to report any refunds or returns
  # after 90 days.
  #
  # 2. Approval process will take place elsewhere and not being handled
  # by this class.

  class Item < DotOne::ApiClient::OrderApi::BaseItem
    attr_accessor :order_number_only, :order_number_with_sku

    def initialize(record = {}, _options = {})
      super(record)
      @click_stat = obtain_transaction(record['Member ID (U1)'])

      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?

      @recorded_at = TimeZone.current.from_utc(
        parse_date_string(
          record['Transaction Date'], record['Transaction Time']
        ),
      )

      # Since using real-time Linkshare Event API, order number contains
      # SKU to make sure uniqueness
      @order_number_only = record['Order ID']
      @order_number_with_sku = [record['Order ID'], record['SKU']].join(':')

      begin
        @order_number = order_number_to_record
      rescue Exception => e
        @order_number = order_number_with_sku
      end

      @total = record['Sales'].gsub(/,/, '').to_f rescue nil
      @true_pay = record['Total Commission'].to_s.gsub(/,/, '').to_f rescue nil
      @status = Order.status_pending
    end

    private

    ##
    # Combines date and time part and parse it
    # to Time object for further process.
    def parse_date_string(date_part, time_part)
      return if date_part.blank? || time_part.blank?

      Time.strptime([date_part, time_part].join(' '), '%m/%d/%y %H:%M:%S')
    end
  end
end
