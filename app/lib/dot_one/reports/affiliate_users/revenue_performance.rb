module DotOne::Reports::AffiliateUsers
  class RevenuePerformance < BasePerformance
    def week_data
      {
        confirmed_revenue: confirmed_revenue,
        pending_revenue: pending_revenue,
        average_confirmed_revenue: average_confirmed_revenue,
        estimation_revenue: estimation_revenue,
        estimation_payable: estimation_payable,
        estimation_margin: estimation_margin,
        margin_ratio: margin_ratio,
      }
    end

    private

    def confirmed_revenue
      Stat.where(approval: AffiliateStat.approval_published)
        .merge(query_by_date_range(Stat, 'published_at'))
        .sum(:true_pay)
    end

    def pending_revenue
      Stat.where(approval: AffiliateStat.approval_pending)
        .merge(query_by_date_range(Stat, 'captured_at'))
        .sum(:true_pay)
    end

    def average_confirmed_revenue
      return 0.0 if published_transactions == 0

      ((confirmed_revenue.to_f / published_transactions) * 100.0).round(2)
    end

    def estimation_revenue
      confirmed_revenue + pending_revenue
    end

    def estimation_payable
      published_affiliate_pay + pending_affiliate_pay
    end

    def estimation_margin
      estimation_revenue - estimation_payable
    end

    def margin_ratio
      return 0.0 if estimation_revenue == 0

      ((estimation_margin.to_f / estimation_revenue) * 100.0).round(2)
    end

    def published_transactions
      Stat.where(approval: AffiliateStat.approval_published)
        .merge(query_by_date_range(Stat, 'published_at'))
        .sum(:conversions)
    end

    def published_affiliate_pay
      Stat.where(approval: AffiliateStat.approval_published)
        .merge(query_by_date_range(Stat, 'published_at'))
        .sum(:affiliate_pay)
    end

    def pending_affiliate_pay
      Stat.where(approval: AffiliateStat.approval_pending)
        .merge(query_by_date_range(Stat, 'captured_at'))
        .sum(:affiliate_pay)
    end
  end
end
