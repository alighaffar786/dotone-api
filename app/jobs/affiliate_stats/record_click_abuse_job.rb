# frozen_string_literal: true

class AffiliateStats::RecordClickAbuseJob < MaintenanceJob
  def perform(params)
    begin
      report = ClickAbuseReport.find_or_initialize_by(params.slice(:token, :error_details))
      report.assign_attributes(params)
      report.blocked = false
      report.count += 1
      report.save!
    rescue Exception => e
      q = ClickAbuseReport.where(params.slice(:token, :error_details))
      count = q.sum(:count)
      limit = q.count - 1

      if limit > 0
        q.limit(limit).delete_all
        q.last&.update(count: count)
      end

      retry
    end
  end
end
