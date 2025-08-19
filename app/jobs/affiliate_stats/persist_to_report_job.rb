# frozen_string_literal: true

class AffiliateStats::PersistToReportJob < TrackingJob
  def perform(ids)
    AffiliateStat.where(id: ids).preload(:aff_hash).find_each do |affiliate_stat|
      DotOne::Utils::Rescuer.no_deadlock do
        affiliate_stat.refresh_conversion_step_snapshot!
        affiliate_stat.mirror_to_redshift
      end
    end
  end
end
