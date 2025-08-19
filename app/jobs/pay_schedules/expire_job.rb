# frozen_string_literal: true

class PaySchedules::ExpireJob < MaintenanceJob
  def perform
    pay_schedules = PaySchedule.where(expired: false).where('ends_at < ?', Time.now)

    pay_schedules.find_each do |record|
      catch_exception { record.update_attribute(:expired, true) }
    end
  end
end
