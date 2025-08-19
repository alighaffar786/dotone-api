class DotOne::Reports::ConversionCounter
  attr_accessor :affiliate_stats, :order_map

  def initialize(affiliate_stats)
    @affiliate_stats = affiliate_stats
    @order_map = Order.where(affiliate_stat_id: affiliate_stats.map(&:id)).group_by(&:affiliate_stat_id)
  end

  def generate
    result = {}

    affiliate_stats.each do |affiliate_stat|
      current = {
        captured_at: affiliate_stat.captured_at.present? ? 1 : 0,
        published_at: affiliate_stat.published_at.present? ? 1 : 0,
        converted_at: affiliate_stat.converted_at.present? ? 1 : 0,
      }

      if orders = order_map[affiliate_stat.id]
        current[:captured_at] += orders.size
        current[:published_at] += orders.select { |order| order.published_at.present? }.count
        current[:converted_at] += orders.select { |order| order.converted_at.present? }.count
      end

      result[affiliate_stat.id] = current
    end

    result
  end
end
