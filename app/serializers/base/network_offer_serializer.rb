class Base::NetworkOfferSerializer < ApplicationSerializer
  translatable_attributes(*NetworkOffer.dynamic_translatable_attributes)
  local_time_attributes(*NetworkOffer.local_time_attributes)
  forexable_attributes(*NetworkOffer.forexable_attributes)

  def commissions
    if affiliate?
      object.commission_details(affiliate: current_user, currency_code: currency_code)
    else
      object.commission_details
    end
  end

  def payouts
    object.payout_details(currency_code)
  end

  def approved_time
    if affiliate?
      object.approved_time_for_affiliate(current_user)
    else
      object.approved_time
    end
  end
end
