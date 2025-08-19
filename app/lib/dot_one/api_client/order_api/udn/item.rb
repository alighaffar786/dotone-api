require 'net/http'
require 'open-uri'
require 'digest'

module DotOne::ApiClient::OrderApi::Udn
  class Item < DotOne::ApiClient::OrderApi::BaseItem
    def initialize(record, _options = {})
      super(record)
      @order_number = record['Odxuid']
      @click_stat = obtain_transaction(record['SiteMebid'])
      @is_multiple_conversion_point = @click_stat&.cached_offer&.multi_conversion_point?
      @recorded_at = Time.parse(record['Feesplitdat']) rescue nil
      @total = record['Payment']

      if record['Odsts']
        @status = status_map_using_odsts(record['Odsts'])
      elsif record['Feesplitsts']
        @status = status_map_using_feesplitsts(record['Feesplitsts'])
      end

      @converted_at = use_own_converted_at # Time.parse(record['Feesplitdat']) rescue nil
    end

    private

    def status_map_using_feesplitsts(raw_value)
      case raw_value
      when 'C'
        Order.status_rejected
      when 'P'
        Order.status_approved
      else # when "W"
        Order.status_pending
      end
    end

    def status_map_using_odsts(raw_value)
      case raw_value
      when 'C'
        Order.status_rejected
      when 'A'
        Order.status_approved
      else # when "P"
        Order.status_pending
      end
    end
  end
end
