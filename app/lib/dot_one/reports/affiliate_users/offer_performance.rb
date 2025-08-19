module DotOne::Reports::AffiliateUsers
  class OfferPerformance < BasePerformance
    def week_data
      {
        total_clicks: total_clicks,
        pending_transactions: pending_transactions,
        published_transactions: published_transactions,
        approved_transactions: approved_transactions,
        rejected_transactions: rejected_transactions,
        inconclusive: inconclusive,
        total_captured_transactions: total_captured_transactions,
        offer_conversion_rate: offer_conversion_rate,
        total_active_offers: total_active_offers,
        converted_offers: converted_offers,
        new_active: new_active,
        new_suspended: new_suspended,
      }
    end

    private

    def total_clicks
      Stat.merge(query_by_date_range(Stat, 'recorded_at')).sum(:clicks)
    end

    def pending_transactions
      Stat.pending.merge(query_by_date_range(Stat, 'captured_at')).sum(:conversions)
    end

    def published_transactions
      Stat.where(approval: AffiliateStat.approval_published)
        .merge(query_by_date_range(Stat, 'published_at'))
        .sum(:conversions)
    end

    def approved_transactions
      Stat.where(approval: AffiliateStat.approval_approved)
        .merge(query_by_date_range(Stat, 'converted_at'))
        .sum(:conversions)
    end

    def rejected_transactions
      Stat.where(approval: AffiliateStat.approval_rejected)
        .merge(query_by_date_range(Stat, 'converted_at'))
        .sum(:conversions)
    end

    def inconclusive
      Stat.where(approval: AffiliateStat.approval_invalid)
        .merge(query_by_date_range(Stat, 'converted_at'))
        .sum(:conversions)
    end

    def total_captured_transactions
      Stat.merge(query_by_date_range(Stat, 'captured_at')).sum(:conversions)
    end

    def offer_conversion_rate
      return 0.0 if total_clicks == 0

      ((total_captured_transactions.to_f / total_clicks.to_f) * 100.0).round(2)
    end

    def total_active_offers
      Offer.where('published_date <= ?', end_date).count
    end

    def converted_offers
      Offer.joins(:offer_variants)
        .where(offers: { id: converted_offer_ids })
        .merge(OfferVariant.active_public)
        .count
    end

    def new_active
      Offer.merge(query_by_date_range(Offer, 'published_date')).count
    end

    def new_suspended
      Offer.merge(query_by_date_range(Offer, 'suspended_at')).count
    end

    def converted_offer_ids
      AffiliateStatConvertedAt.where(approval: AffiliateStat.approval_approved)
        .merge(query_by_date_range(AffiliateStatConvertedAt, 'converted_at'))
        .pluck(:offer_id)
        .uniq
    end
  end
end
