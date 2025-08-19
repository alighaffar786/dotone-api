class Teams::TextCreativeSerializer < Base::TextCreativeSerializer
  attributes :id, :offer_id, :offer_variant_id, :status, :creative_name, :original_price, :discount_price,
    :is_infinity_time, :active_date_start, :active_date_end, :locales, :status_reason, :button_text, :deal_scope,
    :coupon_code, :title, :content_1, :content_2, :client_url, :image_url, :created_at, :id_with_name,
    :ongoing?, :marketing_name, :published_at, :category_ids, :currency_id

  has_many :categories

  has_one :currency
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer
  has_one :offer_variant, serializer: Teams::OfferVariant::MiniSerializer
end
