class Affiliates::NetworkOffer::IndexSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :brand_image_url, :earning_meter, :affiliate_conv_type, :short_description,
    :min_affiliate_pay, :max_affiliate_pay, :min_affiliate_share, :max_affiliate_share, :approved_time,
    :approved_time_num_days, :approval_message, :need_approval, :custom_approval_message, :placement_needed,
    :approval_status, :reapply_note, :status_summary, :status_reason, :mixed_affiliate_pay

  has_many :categories
  has_many :countries
  has_many :media_restrictions

  has_one :default_offer_variant, key: :offer_variant, serializer: Affiliates::OfferVariant::MiniSerializer
  has_one :default_conversion_step, key: :conversion_step, serializer: Affiliates::ConversionStep::MiniSerializer

  def brand_image_url
    object.brand_image_small&.cdn_url
  end
end
