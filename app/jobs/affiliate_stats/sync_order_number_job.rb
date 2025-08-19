# frozen_string_literal: true

class AffiliateStats::SyncOrderNumberJob < MaintenanceJob
  def perform(n_days = nil)
    AffiliateStat.multi_conversions
      .where(order_number: nil)
      .preload(:copy_order)
      .where('captured_at > ?', (n_days || 1).days.ago)
      .find_each do |stat|
        stat.update(order_number: stat.copy_order.order_number)

        STAT_SYNC_ORDER_NUMBER_LOGGER.warn "SYNCING ORDER NUMBER FOR #{stat.id}:\n\t\t#{stat.copy_order.order_number}"
      end
  end
end
