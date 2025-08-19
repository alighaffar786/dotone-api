class Advertisers::ImageCreativeSerializer < Base::ImageCreativeSerializer
  class NetworkOfferSerializer < Base::NetworkOfferSerializer
    attributes :id, :name, :payouts, :destination_url
  end

  attributes :id, :offer_id, :offer_variant_id, :cdn_url, :status, :size, :is_infinity_time, :active_date_start, :active_date_end,
    :locales, :ongoing?, :width, :height, :client_url, :created_at, :updated_at, :file_size,
    :status_reason, :download_counts

  has_one :offer, serializer: NetworkOfferSerializer
end
