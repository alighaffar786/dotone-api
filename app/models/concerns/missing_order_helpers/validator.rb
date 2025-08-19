module MissingOrderHelpers::Validator
  class ClickTimeTooOld < ActiveModel::Validator
    def validate(record)
      if record.click_time_changed? && record.click_time.present? && record.click_time < Time.parse('1900-01-01 00:00:00')
        record.errors.add(:click_time, :too_old)
      end
    end
  end
end
