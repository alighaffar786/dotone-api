# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class TotalOrder < Base
    def generate
      super do
        { this_month: query_this_month, last_month: query_last_month }
      end
    end

    def query_stats(date_range)
      current = stats
        .between(*date_range, :recorded_at, time_zone)
        .stat([:date], [:order_total], currency_code: currency_code, time_zone: time_zone, user_role: :network)
        .index_by { |stat| stat.date.to_date.to_s }

      (date_range[0].to_date..date_range[1].to_date).map do |date|
        current[date.to_s]&.order_total.to_f
      end
    end

    def query_this_month
      date_range = time_zone.local_range(:this_month)
      query_stats(date_range)
    end

    def query_last_month
      date_range = time_zone.local_range(:last_month)
      query_stats(date_range)
    end
  end
end
