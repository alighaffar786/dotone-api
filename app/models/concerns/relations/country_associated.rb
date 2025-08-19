module Relations::CountryAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :country, inverse_of: self.name.tableize

    scope_by_country
  end

  def cached_country
    Country.cached_find(country_id)
  end
end
