class Teams::OfferVariant::MiniSerializer < Base::OfferVariantSerializer
  attributes :id, :status, :destination_url, :can_config_url, :active?
end
