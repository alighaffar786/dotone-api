class Base::AffiliateOfferSerializer < ApplicationSerializer
  local_time_attributes(*AffiliateOffer.local_time_attributes)
  forexable_attributes(*AffiliateOffer.forexable_attributes)

  def approval_status
    if affiliate?
      object.approval_status_for_affiliate
    else
      object.approval_status
    end
  end

  def tracking_url
    object.to_tracking_url
  end

  def offer_variant_status
    object.default_offer_variant&.status
  end
end
