# frozen_string_literal: true

class NetworkOffers::ReindexProductsJob < MaintenanceJob
  def perform(offer_id)
    Product
      .preload_es_relations
      .where(offer_id: offer_id)
      .es_bulk_update
  end
end
