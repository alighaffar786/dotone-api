class Base::TextCreativeSerializer < ApplicationSerializer
  local_time_attributes(*TextCreative.local_time_attributes)

  def tracking_url
    if affiliate? && object.respond_to?(:approval_status) && object.approval_status == AffiliateOffer.approval_status_active
      object.to_tracking_url(current_user)
    end
  end

  def ongoing?
    object.ongoing?(time_zone)
  end

  def marketing_name
    object.offer&.t_offer_name
  end
end
