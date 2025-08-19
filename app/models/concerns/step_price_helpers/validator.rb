module StepPriceHelpers::Validator
  class CustomPayValidator < ActiveModel::Validator
    def validate(record)
      payout_must_be_greater_than_commission(record)
    end

    def payout_must_be_greater_than_commission(record)
      return unless record.conversion_step.true_conv_type == record.conversion_step.affiliate_conv_type

      if record.conversion_step.is_true_share? &&
          record.payout_share.present? &&
          record.payout_share.to_f < record.custom_share.to_f
        record.errors.add :payout_share, record.errors.generate_message(:payout_amount, :invalid)
      end

      if !record.conversion_step.is_true_share? &&
          record.forex_payout_amount.present? &&
          record.forex_payout_amount.to_f < record.forex_custom_amount.to_f
        record.errors.add :payout_amount, record.errors.generate_message(:payout_amount, :invalid)
      end
    end
  end
end
