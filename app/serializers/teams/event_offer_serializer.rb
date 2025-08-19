class Teams::EventOfferSerializer < Base::EventOfferSerializer
  class ConversionStepSerializer < Base::ConversionStepSerializer
    original_attributes(*ConversionStep.forexable_attributes)

    attributes :id, :affiliate_pay, :max_affiliate_pay, :affiliate_pay_flexible?, :true_pay, :true_currency_id

    has_one :true_currency
  end

  attributes :id, :name, :short_description, :brand_image_url, :published_date, :approval_message, :network_id,
    :category_ids, :is_private, :country_ids, :translation_stats, :term_ids, :t_short_description_static?,
    :affiliate_pay_flexible?

  has_one :network, serializer: Teams::Network::MiniSerializer
  has_one :event_info
  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariant::EventVariantSerializer
  has_one :default_conversion_step, key: :conversion_step, serializer: ConversionStepSerializer

  has_many :categories
  has_many :countries

  EventOffer.dynamic_translatable_attribute_types.each_key do |key|
    has_many "#{key}_translations".to_sym
  end
end
