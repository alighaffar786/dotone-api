class Advertisers::NetworkOffer::MiniSerializer < Base::NetworkOfferSerializer
  attributes :id, :name

  conditional_attributes :status, if: :include_status?

  def include_status?
    [
      Advertisers::AffiliateStatSerializer,
      Advertisers::TextCreativeSerializer,
      Advertisers::AffiliateOfferSerializer,
    ].include?(context_class)
  end
end
