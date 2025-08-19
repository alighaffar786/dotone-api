class Teams::NetworkOffer::SearchSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :destination_url, :network_id

  has_many :active_offer_variants, key: :offer_variants, serializer: Teams::OfferVariant::SearchSerializer, if: :include_offer_variants?
  has_many :categories, if: :include_categories?

  def include_offer_variants?
    instance_options[:offer_variants]
  end

  def include_categories?
    instance_options[:categories]
  end
end
