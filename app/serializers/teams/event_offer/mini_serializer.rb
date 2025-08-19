class Teams::EventOffer::MiniSerializer < Base::EventOfferSerializer
  attributes :id, :name

  attribute :affiliate_pay_flexible?, if: :for_event_affiliate_offer?

  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariant::EventVariantSerializer,
    if: :for_event_affiliate_offer?

  def for_event_affiliate_offer?
    context_class == Teams::EventAffiliateOfferSerializer
  end
end
