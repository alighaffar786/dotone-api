class Affiliates::TextCreative::SearchSerializer < Base::TextCreativeSerializer
  attributes :id, :status, :original_price, :discount_price, :button_text, :coupon_code, :title, :content_1, :content_2,
    :image_url, :marketing_name, :tracking_url

  has_many :category_groups
  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer
end
