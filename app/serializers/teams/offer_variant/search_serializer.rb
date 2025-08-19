class Teams::OfferVariant::SearchSerializer < Base::OfferVariantSerializer
  attributes :id, :full_name, :deeplinkable?, :destination_url
end
