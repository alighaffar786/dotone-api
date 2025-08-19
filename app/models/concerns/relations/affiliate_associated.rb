module Relations::AffiliateAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :affiliate, inverse_of: self.name.tableize

    scope_by_affiliate
  end

  module ClassMethods
    def belongs_to_affiliate(**options)
      belongs_to :affiliate, **{ inverse_of: name.tableize }.merge(options)
    end
  end

  def cached_affiliate
    Affiliate.cached_find(affiliate_id)
  end
end
