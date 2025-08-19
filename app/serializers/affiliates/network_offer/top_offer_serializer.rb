class Affiliates::NetworkOffer::TopOfferSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :brand_image_url, :affiliate_conv_type, :manager_insight, :custom_epc,
    :min_affiliate_pay, :max_affiliate_pay, :min_affiliate_share, :max_affiliate_share, :mixed_affiliate_pay

  has_many :top_traffic_sources, serializer: AffiliateTag::TopTrafficSourceSerializer

  def name
    object.name
  end

  def brand_image_url
    object.brand_image_medium&.cdn_url
  end
end
