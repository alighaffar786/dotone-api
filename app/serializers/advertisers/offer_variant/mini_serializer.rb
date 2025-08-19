class Advertisers::OfferVariant::MiniSerializer < Base::OfferVariantSerializer
  attributes :id, :status, :can_config_url, :active?
end
