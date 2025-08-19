class Affiliates::EventOffer::RecentSerializer < Base::EventOfferSerializer
  class EventInfoSerializer < Base::EventInfoSerializer
    attributes :id, :event_type, :published_by

    has_one :media_category
  end

  attributes :id, :brand_image_url, :total_value, :max_affiliate_pay, :affiliate_pay_flexible?

  has_one :event_info, serializer: EventInfoSerializer
end
