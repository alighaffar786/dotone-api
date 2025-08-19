class Base::AffiliatePaymentSerializer < ApplicationSerializer
  local_time_attributes(*AffiliatePayment.local_date_attributes)
  translatable_attributes(*AffiliatePayment.static_translatable_attributes)

  def total_fees
    return object.total_fees unless total_fees_map

    total_fees_map[object.id].to_f
  end

  private

  def total_fees_map
    instance_options[:total_fees]
  end
end
