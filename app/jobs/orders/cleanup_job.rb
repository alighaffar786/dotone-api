# frozen_string_literal: true

class Orders::CleanupJob < MaintenanceJob
  def perform(start_at: nil, end_at: nil)
    start_at = (Date.parse(start_at) rescue 7.days.ago).beginning_of_day
    end_at = (Date.parse(end_at) rescue Date.today).end_of_day

    orders = Order
      .where(recorded_at: start_at..end_at)
      .group(:order_number, :affiliate_stat_id, :offer_id, :step_name, :status)
      .count
      .select { |keys, count| count > 1 }
      .map do |keys, count|
        order_number, affiliate_stat_id, offer_id, step_name, status = keys

        ORDER_CLEANUP_LOGGER.warn "  Found #{count} for Order Number: #{order_number}, Click ID: #{affiliate_stat_id}..."

        destroyed = Order
          .where(order_number: order_number, affiliate_stat_id: affiliate_stat_id, offer_id: offer_id, step_name: step_name, status: status)
          .order(id: :desc)
          .limit(count - 1)
          .destroy_all

        ORDER_CLEANUP_LOGGER.warn "   Removing #{destroyed.size}"
      end
  end
end
