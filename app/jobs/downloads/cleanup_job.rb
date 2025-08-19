# frozen_string_literal: true

class Downloads::CleanupJob < MaintenanceJob
  NUM_DAYS = 30

  def perform
    Download.clean_up(NUM_DAYS)
  end
end
