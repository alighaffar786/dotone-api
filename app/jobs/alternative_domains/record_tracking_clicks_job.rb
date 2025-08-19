# frozen_string_literal: true

class AlternativeDomains::RecordTrackingClicksJob < MaintenanceJob
  def perform(url)
    AlternativeDomain.record_tracking_clicks!(url)
  end
end
