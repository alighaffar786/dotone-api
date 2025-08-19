class Teams::MktSiteSerializer < ApplicationSerializer
  attributes :id, :domain, :created_at, :offer_id, :affiliate_id, :network_id,
    :verified, :accepted_origins, :platform

  class NetworkOfferSerializer < Teams::NetworkOffer::MiniSerializer
    attributes :pixel_last_used_at

    def pixel_last_used_at
      object.js_conversion_pixel&.updated_at
    end
  end

  has_one :offer, serializer: NetworkOfferSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer
  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer
end
