module PayScheduleHelpers::Validator
  class PayValidator < ActiveModel::Validator
    def validate(record)
      payout_must_be_greater_than_commission(record)
      at_least_one_payout_must_exist(record)
    end

    def payout_must_be_greater_than_commission(record)
      return unless record.conversion_step.true_conv_type == record.conversion_step.affiliate_conv_type

      if record.conversion_step.is_true_share? &&
          record.true_share.present? &&
          record.true_share.to_f < record.affiliate_share.to_f
        record.errors.add :true_share, record.errors.generate_message(:true_pay, :invalid)
      end

      if !record.conversion_step.is_true_share? &&
          record.true_pay.present? &&
          record.true_pay.to_f < record.affiliate_pay.to_f
        record.errors.add :true_pay, record.errors.generate_message(:true_pay, :invalid)
      end
    end

    def at_least_one_payout_must_exist(record)
      return unless [record.affiliate_pay, record.true_pay, record.true_share, record.affiliate_share].all? { |value| value.to_f <= 0 }

      record.errors.add(:base, :invalid_payout)
    end
  end

  class DateValidator < ActiveModel::Validator
    def validate(record)
      dates_must_in_the_future(record)
    end

    def dates_must_in_the_future(record)
      if record.starts_at.present? && record.starts_at.to_date < (Time.now - 1.day).utc.to_date
        record.errors.add :starts_at_local, record.errors.generate_message(:starts_at_local, :invalid)
      end

      if record.ends_at.present? && record.ends_at.to_date < Time.now.utc.to_date
        record.errors.add :ends_at_local, record.errors.generate_message(:ends_at_local, :invalid)
      end

      if record.starts_at.present? && record.ends_at.present? && record.starts_at.to_date > record.ends_at.to_date
        record.errors.add :ends_at_local, record.errors.generate_message(:ends_at_local, :invalid_range)
      end
    end
  end
end
