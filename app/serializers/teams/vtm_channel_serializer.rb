class Teams::VtmChannelSerializer < ApplicationSerializer
  class MktSiteSerializer < ApplicationSerializer
    attributes :id, :domain
  end

  class VtmPixelSerializer < ApplicationSerializer
    attributes :id, :step_name, :order_conv_pixel
  end

  attributes :id, :name, :conv_pixel, :visit_pixel

  has_many :vtm_pixels, serializer: VtmPixelSerializer

  has_one :mkt_site, serializer: MktSiteSerializer
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer
end
