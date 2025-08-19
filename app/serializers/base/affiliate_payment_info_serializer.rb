class Base::AffiliatePaymentInfoSerializer < ApplicationSerializer
  maskable_attributes(*AffiliatePaymentInfo.maskable_attributes)
  local_time_attributes(*AffiliatePaymentInfo.local_time_attributes)
  forexable_attributes(*AffiliatePaymentInfo.forexable_attributes)

  def preferred_currency_name
    Currency.t_code_name(object.preferred_currency)
  end
end
