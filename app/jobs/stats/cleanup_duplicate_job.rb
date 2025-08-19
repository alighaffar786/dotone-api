# frozen_string_literal: true

class Stats::CleanupDuplicateJob < MaintenanceJob
  def perform(date_str = nil)
    if date_str
      date = Date.parse(date_str)
      ids = Stat
        .where(updated_at: date.beginning_of_day..date.end_of_day)
        .group(:id)
        .count
        .select { |k, v| v > 1 }
        .keys

      STAT_DUPLICATE_CLEANUP_LOGGER.warn("Found #{ids.size} duplicates for #{date}")
      STAT_DUPLICATE_CLEANUP_LOGGER.warn(ids.join(','))

      Stat.where(id: ids).delete_all

      ids.each_slice(100) do |group|
        AffiliateStats::SyncJob.perform_later(ids: group)
      end
    else
      (1.month.ago.to_date..1.day.ago.to_date).each do |date|
        self.class.perform_later(date.to_s)
      end
    end
  end
end
