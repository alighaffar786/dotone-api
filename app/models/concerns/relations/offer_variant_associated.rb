module Relations::OfferVariantAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :offer_variant, inverse_of: self.name.tableize

    scope_by_offer_variant
  end

  def cached_offer_variant
    OfferVariant.cached_find(offer_variant_id)
  end
end
