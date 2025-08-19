# frozen_string_literal: true

class NetworkOffers::NotifyUpcomingPauseJob < NotificationJob
  def perform
    notify_offers(24)
    notify_offers(48)
  end

  def notify_offers(hour)
    expired_at = hour.hours.from_now

    NetworkOffer
      .active
      .joins(:aff_hash)
      .where("aff_hashes.flag LIKE ?", "%will_notify_#{hour}_hour_paused: 1%")
      .where("aff_hashes.flag NOT LIKE ?", "%notified_#{hour}_hour_pause: 1%")
      .where.not(no_expiration: true)
      .where('expired_at <= ?', expired_at)
      .find_each(batch_size: 250) do |offer|
        offer.active_affiliates.find_each do |affiliate|
          next unless affiliate.offer_status_notification_enabled?

          AffiliateMailer.xhour_offer_paused(offer, affiliate, hour, cc: true).deliver_later
        end

        offer.notified_24_hour_pause = true if hour == 24
        offer.notified_48_hour_pause = true if hour == 48
    end
  end
end
