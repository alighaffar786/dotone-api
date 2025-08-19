class CategorySerializer < ApplicationSerializer
  translatable_attributes(*Category.static_translatable_attributes)

  attributes :id, :name

  has_one :category_group, if: :include_category_group?

  def include_category_group?
    context_class == Teams::NetworkOfferSerializer ||
    context_class == Teams::TextCreativeSerializer ||
    context_class == Teams::EventOfferSerializer ||
    context_class == Teams::AffiliateProspectSerializer
  end
end
