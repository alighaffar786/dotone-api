module AdvertiserBalanceHelpers::Validator
  class AdvertiserBalanceValidator < ActiveModel::Validator
    def validate(record)
      handle_recorded_at_less_than_previous_record(record)
    end

    private

    def handle_recorded_at_less_than_previous_record(record)
      return true if record.previous_one.blank?

      if record.recorded_at.present? && record.previous_one.recorded_at.present? && (record.recorded_at - record.previous_one.recorded_at < 0.0)
        record.errors.add :recorded_at, record.errors.generate_message(:recorded_at, :invalid_recorded_at)
      end
    end
  end
end
