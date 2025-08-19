class Affiliates::PopulateTopOffersJob < MaintenanceJob
  def perform
    stats = query_stats

    Affiliate.select(:id).preload(:aff_hash).find_each do |affiliate|
      captured = stats[affiliate.id] || []

      next if affiliate.aff_hash.blank? && captured.blank?

      affiliate.system_flag_top_offer_stats = captured.first(3).map { |x| [x.offer_id, x.captured] }
    end
  end

  def query_stats
    time_zone = TimeZone.platform
    range = time_zone.local_range(:last_30_days)

    Stat
      .has_conversions
      .stat([:offer_id, :affiliate_id], [:captured], user_role: :affiliate)
      .between(*range, :recorded_at, time_zone)
      .order(captured: :desc)
      .group_by(&:affiliate_id)
  end
end
