# frozen_string_literal: true

class Stats::ArchiveJob < MaintenanceJob
  def perform(year_month_str = nil)
    DotOne::Stats::Archiver.new(year_month_str).archive!
  end
end
