class Teams::EventAffiliateOfferSerializer < Base::AffiliateOfferSerializer
  attributes :id, :offer_id, :affiliate_id, :created_at

  conditional_attributes :phone_number, :shipping_address, :event_shipment_notes, :event_supplement_notes, :site_info_url,
    :event_draft_url, :event_draft_notes, :event_published_url, :event_contract_signed, :event_contract_signature,
    :event_contract_signed_ip_address, :status_reason, :event_promotion_notes, :approval_status, :status_summary,
    :effective_affiliate_pay, if: :can_read_affiliate?

  original_attributes :effective_affiliate_pay

  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer
  has_one :event_offer, serializer: Teams::EventOffer::MiniSerializer

  def site_info_url
    object.site_info&.url
  end
end
