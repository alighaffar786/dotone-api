# frozen_string_literal: true

class Archive::ClearServerLogJob < MaintenanceJob
  EXCLUDED_LOGS = [
    'log/sidekiq.log',
  ].freeze

  def perform
    Dir.glob('log/**/*.log').each do |path|
      next if EXCLUDED_LOGS.include?(path)

      File.open(path, 'w') do |file|
        file.truncate(0)
      end
    end
  end
end
