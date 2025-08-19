# frozen_string_literal: true

class SiteInfos::RefreshMetricsJob < ApiPullJob
  MAX_ATTEMPS = 5

  def perform(site_info_ids = nil, options = {})
    attemps = options.delete(:attemps) || 0

    site_infos = if site_info_ids.present?
      SiteInfo.where(id: site_info_ids)
    else
      SiteInfo.connected
    end

    site_infos.find_each do |site_info|
      catch_exception do
        site_info.refresh_metrics(options)
      rescue Exception => e
        if attemps < MAX_ATTEMPS
          SiteInfos::RefreshMetricsJob.set(wait: 5.minutes).perform_later(site_info.id, retry: true, attemps: attemps + 1)
        else
          raise e
        end
      end
    end
  end
end
