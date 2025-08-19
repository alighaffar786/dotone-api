class Affiliates::PopulateConversionCountJob < MaintenanceJob
  def perform
    stats = query_stats
    affiliate_ids = stats.keys

    Affiliate.where(id: affiliate_ids).select(:id, :conversion_count).find_each do |affiliate|
      conversion_count = stats[affiliate.id].captured

      next if affiliate.conversion_count == conversion_count

      affiliate.update_columns(conversion_count: conversion_count, updated_at: Time.now)
    end

    Affiliate.where.not(id: affiliate_ids).update_all(conversion_count: 0, updated_at: Time.now)
  end

  def query_stats
    time_zone = TimeZone.platform
    range = time_zone.local_range(:last_90_days)

    Stat
      .has_conversions
      .stat([:affiliate_id], [:captured], user_role: :affiliate)
      .between(*range, :recorded_at, time_zone)
      .index_by(&:affiliate_id)
  end
end
