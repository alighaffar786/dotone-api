class Affiliates::AffiliateStatSerializer < Base::AffiliateStatSerializer
  class EventOfferSerializer < Base::EventOfferSerializer
    attributes :id, :name
  end

  attributes :transaction_id, :offer_variant_id, :image_creative_id, :text_creative_id, :offer_id,
    :approval, :approvals, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5,
    :browser, :browser_version, :device_brand, :device_model, :device_type, :ip_address,
    :recorded_at, :captured_at, :published_at, :converted_at, :aff_uniq_id, :affiliate_conv_type, :affiliate_pay,
    :http_referer, :referer_domain, :order_total, :step_label, :is_event_offer

  has_one :copy_order, key: :order, if: :full_scope_requested?
  has_one :offer
  has_one :country

  def self.serializer_for(model, options)
    case model.class.name
    when 'EventOffer'
      EventOfferSerializer
    when 'NetworkOffer'
      Affiliates::NetworkOffer::MiniSerializer
    else
      super
    end
  end

  def is_event_offer
    object.offer.is_a?(EventOffer)
  end
end
