class Affiliates::EventInfoSerializer < Base::EventInfoSerializer
  attributes :id, :related_offer_id, :event_type, :value, :popularity, :popularity_unit, :availability_type,
    :fulfillment_type, :days_left_to_apply

  has_one :event_media_category
  has_one :media_category
end
