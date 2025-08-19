module Relations::OfferAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :offer, inverse_of: self.name.tableize

    scope_by_offer
  end

  module ClassMethods
    def belongs_to_offer(**options)
      belongs_to :offer, **{ inverse_of: name.tableize }.merge(options)
    end
  end

  def cached_offer
    Offer.cached_find(offer_id)
  end
end
