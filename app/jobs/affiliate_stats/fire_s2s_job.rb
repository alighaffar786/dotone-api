# frozen_string_literal: true

class AffiliateStats::FireS2sJob < TrackingJob
  def perform(ids, options = {})
    confirmed = options.delete(:confirmed)
    affiliate_stats = AffiliateStat.where(id: ids)

    affiliate_stats.find_each do |stat|
      if confirmed
        stat.fire_confirmed_s2s_routine(options)
      else
        stat.fire_s2s_routine(options)
      end
    end
  end
end
