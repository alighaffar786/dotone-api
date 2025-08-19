module Relations::NetworkAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :network, inverse_of: self.name.tableize

    scope_by_network
    scope_by_billing_region(:network_id)
  end

  def cached_network
    Network.cached_find(network_id)
  end
end
