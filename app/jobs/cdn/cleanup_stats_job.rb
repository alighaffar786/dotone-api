# frozen_string_literal: true

class Cdn::CleanupStatsJob < ApplicationJob
  queue_as :cdn

  def perform
    [OfferStat, UniqueViewStat].each do |stats|
      stats.where('date < ?', 6.months.ago).delete_all
    end
  end
end
