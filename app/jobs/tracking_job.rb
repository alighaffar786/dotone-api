# frozen_string_literal: true

class TrackingJob < ApplicationJob
  queue_as :tracking
end
