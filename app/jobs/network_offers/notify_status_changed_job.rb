# frozen_string_literal: true

class NetworkOffers::NotifyStatusChangedJob < NotificationJob
  def perform(id)
    @network_offer = NetworkOffer.find(id)

    @network_offer.active_affiliates.find_each(batch_size: 250) do |affiliate|
      notify(affiliate)
    end
  end

  def notify(affiliate)
    return unless affiliate.offer_status_notification_enabled?

    if paused?
      AffiliateMailer.immediate_offer_paused(@network_offer, affiliate, cc: true).deliver_later
    else
      AffiliateMailer.immediate_offer_status_changed(@network_offer, affiliate, offer_status, cc: true).deliver_later
    end
  end

  def paused?
    [OfferVariant.status_paused, OfferVariant.status_suspended].include?(@network_offer.status)
  end

  def offer_status
    if OfferVariant.status_considered_active.include?(@network_offer.status)
      'Active'
    else
      @network_offer.status
    end
  end
end
