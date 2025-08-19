# frozen_string_literal: true

class Affiliates::UpdateLoginCountJob < MaintenanceJob
  discard_on ActiveRecord::RecordNotFound

  # To get login count for the last 30 days from traces table
  def perform(id)
    @affiliate = Affiliate.find(id)

    records = @affiliate.traces.with_verb('logins').where('created_at >= ?', 30.days.ago).order(:created_at)

    return if records.empty?

    catch_exception do
      @affiliate.update_columns(
        login_count: records.count,
        last_request_at: records.last.created_at,
        updated_at: Time.now,
      )
    end
  end
end
