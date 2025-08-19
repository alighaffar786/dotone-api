class Teams::ImageCreativeSerializer < Base::ImageCreativeSerializer
  attributes :id, :offer_id, :offer_variant_id, :name, :created_at, :locales, :is_infinity_time, :active_date_start, :active_date_end,
    :ongoing?, :client_url, :cdn_url, :status, :download_counts, :status_reason, :internal?, :updated_at

  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :offer_variant, serializer: Teams::OfferVariant::MiniSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer
end
