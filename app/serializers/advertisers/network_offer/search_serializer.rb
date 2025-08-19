class Advertisers::NetworkOffer::SearchSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :destination_url

  conditional_attributes :mkt_site_id, if: :include_mkt_site?

  has_many :active_offer_variants, key: :offer_variants, if: :include_offer_variants?

  def include_offer_variants?
    instance_options[:offer_variants]
  end

  def include_mkt_site?
    instance_options[:with_mkt_site]
  end

  def mkt_site_id
    object.mkt_site&.id
  end
end
