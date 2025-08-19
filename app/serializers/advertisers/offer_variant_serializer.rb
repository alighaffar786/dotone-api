class Advertisers::OfferVariantSerializer < Base::OfferVariantSerializer
  attributes :id, :offer_id, :is_default, :status, :active?, :full_name, :destination_url, :deeplinkable?
end
