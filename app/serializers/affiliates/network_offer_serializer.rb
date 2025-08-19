class Affiliates::NetworkOfferSerializer < Base::NetworkOfferSerializer
  attributes :id, :network_id, :name, :brand_image_url, :short_description, :published_date, :brand_background,
    :product_description, :target_audience, :suggested_media, :other_info,
    :captured_time, :captured_time_num_days, :published_time, :published_time_num_days, :approved_time,
    :approved_time_num_days, :attribution_type, :track_device, :deeplinkable?, :has_ad_link?,
    :has_native_ads?, :has_data_feed?, :has_banners?, :approval_message, :destination_url, :need_approval,
    :custom_approval_message, :placement_needed, :commissions, :mixed_affiliate_pay, :destination_urls

  has_many :categories
  has_many :countries
  has_many :media_restrictions
  has_one :default_offer_variant, key: :offer_variant, serializer: Affiliates::OfferVariant::MiniSerializer
  has_one :default_conversion_step, key: :conversion_step

  def brand_image_url
    object.brand_image_medium&.cdn_url
  end

  def destination_url
    object.destination_url.presence || object.default_offer_variant.destination_url.to_s.gsub(TOKEN_SERVER_SUBID, '').presence
  end
end
