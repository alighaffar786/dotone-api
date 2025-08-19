class Teams::EventOffer::IndexSerializer < Base::EventOfferSerializer
  class ConversionStepSerializer < Base::ConversionStepSerializer
    attributes :id, :affiliate_pay, :max_affiliate_pay, :affiliate_pay_flexible, :true_pay
  end

  attributes :id, :network_id, :name, :brand_image_url, :request_count, :published_date, :is_private, :translation_stats

  has_many :categories
  has_many :countries

  has_one :network, serializer: Teams::Network::MiniSerializer, if: :can_read_network?
  has_one :event_info
  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariant::EventVariantSerializer
  has_one :default_conversion_step, key: :conversion_step, serializer: ConversionStepSerializer
end
