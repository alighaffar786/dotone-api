class V2::Affiliates::ImageCreativeSerializer < Base::ImageCreativeSerializer
  attributes :id, :cdn_url, :is_infinity_time, :active_date_start, :active_date_end, :width, :height,
    :tracking_url, :offer_id, :offer_variant_id

  has_one :offer, serializer: V2::Affiliates::NetworkOffer::MiniSerializer
end
