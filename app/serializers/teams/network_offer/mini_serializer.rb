class Teams::NetworkOffer::MiniSerializer < Base::NetworkOfferSerializer
  attributes :id, :name

  conditional_attributes :status, :conversion_point, if: :for_stat?

  has_many :group_tags, if: :include_group_tags?

  def for_stat?
    [
      Teams::AffiliateStatSerializer,
      Teams::AffiliateStat::IndexSerializer,
    ].include?(context_class)
  end

  def include_group_tags?
    [
      Teams::AffiliateOfferSerializer,
      Teams::ImageCreativeSerializer,
    ].include?(context_class)
  end
end
