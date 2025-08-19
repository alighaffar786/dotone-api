# frozen_string_literal: true

class AffiliateStats::SyncClickIdJob < MaintenanceJob
  def perform(start_at = nil, end_at = nil)
    if start_at.present?
      STAT_SYNC_CLICK_ID_LOGGER.warn "QUERY TIME: #{start_at}"

      Order
        .between(start_at, end_at, :recorded_at)
        .preload(copy_stat: [copy_order: :affiliate_stat])
        .find_each do |order|
          STAT_SYNC_STAT_MISSING_LOGGER.warn order.id if order.copy_stat.blank?

          click_id = order.copy_stat&.original_id

          next if click_id.blank? || order.affiliate_stat_id == click_id

          catch_exception do
            STAT_SYNC_CLICK_ID_LOGGER.warn "SYNCING CLICK ID FOR #{order.order_number}:\n\t\t#{click_id}"
            order.update!(affiliate_stat_id: click_id)
          end
        end
    else
      start_at ||= Time.parse('2024-06-08 13:00')
      end_at ||= start_at + 1.hour

      while start_at > 1.year.ago
        self.class.perform_later(start_at, end_at)
        end_at = start_at
        start_at = start_at - 1.hour
      end
    end
  end
end
