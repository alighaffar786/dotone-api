class AffiliateStats::RecordConversionStepSnapshotJob < TrackingJob
  def perform(click_id, **options)
    affiliate_stat = AffiliateStat.find_by_id(click_id)
    affiliate_stat.refresh_conversion_step_snapshot!(options[:enforce])
  end
end
