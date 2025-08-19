class MissingOrders::CloseJob < MaintenanceJob
  def perform
    MISSING_ORDER_LOGGER.info("[#{Time.now}] Starting...")

    statuses = [
      MissingOrder.status_approved,
      MissingOrder.status_rejected,
      MissingOrder.status_rejected_by_admin,
      MissingOrder.status_rejected_by_advertiser,
    ]

    MissingOrder
      .where(status: statuses)
      .joins(:order)
      .preload(order: :copy_stat)
      .find_each do |missing_order|
        next if missing_order.order&.copy_stat&.considered_pending?(:network)

        catch_exception do
          status_was = missing_order.status
          missing_order.update!(status: MissingOrder.status_completed)
          MISSING_ORDER_LOGGER.info(" [#{Time.now}] [ID: #{missing_order.id}] success update from #{status_was}")
        end
      end

    MISSING_ORDER_LOGGER.info("[#{Time.now}] Done.")
  end
end
