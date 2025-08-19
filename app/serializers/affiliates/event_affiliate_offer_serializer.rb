class Affiliates::EventAffiliateOfferSerializer < Base::AffiliateOfferSerializer
  attributes :id, :offer_id, :site_info_id, :approval_status, :active?, :event_promotion_notes, :event_shipment_notes,
    :event_supplement_notes, :shipping_address, :phone_number, :event_contract_signed, :event_contract_signature,
    :event_contract_signed_at, :event_draft_url, :event_draft_notes, :event_published_url, :status_reason, :status_summary

  attribute :requested_affiliate_pay, if: :active?

  def active?
    object.considered_approved? || object.considered_selected?
  end
end
