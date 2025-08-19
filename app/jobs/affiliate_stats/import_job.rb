# frozen_string_literal: true

class AffiliateStats::ImportJob < ApplicationJob
  queue_as :default

  def perform(upload_id, options = {})
    if exceeds_concurrent_limit?(upload_id)
      self.class.set(wait: 60.minutes).perform_later(upload_id, options)
      return
    end

    catch_exception do
      AffiliateStat.import_conversions(upload_id, options)
    end
  end

  private

  def exceeds_concurrent_limit?(upload_id)
    total_rows = Upload.in_progress
      .where.not(id: upload_id).where(descriptions: 'Offer Conversion Upload').sum { |upload| upload.csv_rows.size }
    total_rows >= 10_000
  end
end
