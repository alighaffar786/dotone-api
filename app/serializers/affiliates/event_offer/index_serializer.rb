class Affiliates::EventOffer::IndexSerializer < Base::EventOfferSerializer
  attributes :id, :brand_image_url, :name, :short_description, :total_value,
    :affiliate_pay, :approval_status, :max_affiliate_pay, :affiliate_pay_flexible?

  has_many :categories
  has_many :countries

  has_one :event_info

  def brand_image_url
    object.affiliate_brand_image&.cdn_url
  end
end
