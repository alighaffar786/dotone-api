class Affiliates::AffiliateOfferSerializer < Base::AffiliateOfferSerializer
  attributes :id, :offer_id, :approval_status, :status_summary, :status_reason, :reapply_note, :has_cap?,
    :conversion_so_far, :cap_size, :cap_type, :backup_redirect, :active?, :direct_tracking_url

  def active?
    object.offer_variant.considered_positive? && approval_status == AffiliateOffer.approval_status_active
  end

  def direct_tracking_url
    return unless active?

    tracking_url
  end
end
