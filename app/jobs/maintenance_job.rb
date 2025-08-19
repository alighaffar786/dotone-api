# frozen_string_literal: true

class MaintenanceJob < ApplicationJob
  queue_as :maintenance
end
