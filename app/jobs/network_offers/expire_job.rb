# frozen_string_literal: true

class NetworkOffers::ExpireJob < MaintenanceJob
  def perform
    NetworkOffer
      .active
      .where.not(no_expiration: true)
      .where('offers.expired_at <= ?', Time.now)
      .preload(:active_offer_variants)
      .find_each do |offer|
        offer.active_offer_variants.each do |variant|
          variant.update!(status: OfferVariant.status_paused)
        end

        NetworkOffers::NotifyStatusChangedJob.perform_later(offer.id)
      end
  end
end
