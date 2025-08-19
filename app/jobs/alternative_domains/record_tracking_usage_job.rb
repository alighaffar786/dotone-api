# frozen_string_literal: true

class AlternativeDomains::RecordTrackingUsageJob < MaintenanceJob
  def perform(url)
    AlternativeDomain.record_tracking_usage!(url)
  end
end
