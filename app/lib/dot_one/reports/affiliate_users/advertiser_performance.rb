module DotOne::Reports::AffiliateUsers
  class AdvertiserPerformance < BasePerformance
    def week_data
      {
        new_entry: new_entry_count,
        organic_entry: organic_entry_count,
        total_advertisers: total_advertisers_count,
        active_advertisers: active_advertisers_count,
        paused_advertisers: paused_advertisers_count,
        suspended_advertisers: suspended_advertisers_count,
        have_order_captured: have_order_captured_count,
        advertiser_with_captured_ratio: advertiser_with_captured_ratio,
        have_uploaded_creative_count: have_uploaded_creative_count,
        have_uploaded_nsa_count: have_uploaded_nsa_count,
      }
    end

    private

    def new_entry_count
      Network.where.not(recruiter_id: nil)
        .merge(query_by_date_range(Network, 'created_at'))
        .count
    end

    def organic_entry_count
      Network.where(recruiter_id: nil)
        .merge(query_by_date_range(Network, 'created_at'))
        .count
    end

    def total_advertisers
      Network.merge(query_by_end_date(Network, 'created_at'))
    end

    def total_advertisers_count
      total_advertisers.count
    end

    def active_advertisers_count
      total_advertisers.where(status: 'Active').count
    end

    def paused_advertisers_count
      total_advertisers.where(status: 'Paused').count
    end

    def suspended_advertisers_count
      total_advertisers.where(status: 'Suspended').count
    end

    def have_order_captured_count
      total_advertisers.joins(:affiliate_stat_captured_ats)
        .merge(query_by_date_range(AffiliateStatCapturedAt, 'captured_at'))
        .count
    end

    def advertiser_with_captured_ratio
      ((have_order_captured_count / active_advertisers_count) * 100).round(2)
    rescue StandardError
      0
    end

    def have_uploaded_creative_count
      total_advertisers.joins(:image_creatives)
        .merge(query_by_date_range(ImageCreative, 'created_at'))
        .count
    end

    def have_uploaded_nsa_count
      total_advertisers.joins(:text_creatives)
        .merge(query_by_date_range(TextCreative, 'created_at'))
        .count
    end
  end
end
