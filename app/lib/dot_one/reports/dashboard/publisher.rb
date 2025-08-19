# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class Publisher < Base
    RECORD_LIMIT = 5

    def generate
      super do
        date_range = time_zone.local_range(:last_30_days)
        stats
          .stat([:affiliate_id], [:clicks, :captured, :order_total], {
            user_role: :network,
            time_zone: time_zone,
            currency_code: currency_code,
            sort_field: :order_total,
            sort_order: :desc
          })
          .between(*date_range, :recorded_at)
          .limit(RECORD_LIMIT)
          .map do |stat|
            {
              affiliate_id: stat.affiliate_id,
              clicks: stat.clicks,
              total_orders: stat.captured,
              total_revenue: stat.order_total,
            }
          end
      end
    end
  end
end
