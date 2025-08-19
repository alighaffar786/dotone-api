class V2::Affiliates::TextCreativeSerializer < Base::TextCreativeSerializer
  attributes :id, :original_price, :discount_price, :is_infinity_time, :active_date_start,
    :active_date_end, :button_text, :coupon_code, :title, :content_1, :content_2,
    :image_url, :tracking_url, :offer_id, :offer_variant_id, :affiliate_pay, :affiliate_share

  has_one :offer, serializer: V2::Affiliates::NetworkOffer::MiniSerializer

  def tracking_url
    object.to_tracking_url(current_user)
  end

  def affiliate_pay
    object.max_affiliate_pay&.to_f&.round(2)
  end

  def affiliate_share
    object.max_affiliate_share&.to_f&.round(2)
  end
end
