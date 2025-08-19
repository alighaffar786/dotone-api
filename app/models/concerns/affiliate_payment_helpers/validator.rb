module AffiliatePaymentHelpers::Validator
  class AffiliatePaymentValidator < ActiveModel::Validator
    def validate(record)
      redeem_should_not_exceed_total_commissions(record)
      redeem_should_not_lower_than_minimum_redeem_amount(record)
      validate_overlapped(record)
    end

    private

    def redeem_should_not_exceed_total_commissions(record)
      return true unless record.status == AffiliatePayment.status_redeemed

      return unless record.redeemed_amount.to_f > record.total_commissions

      record.errors.add :redeemed_amount, :invalid_amount
    end

    def redeem_should_not_lower_than_minimum_redeem_amount(record)
      return true unless record.status == AffiliatePayment.status_redeemed

      currency_code = record.preferred_currency.downcase.to_sym rescue nil
      return false if currency_code.blank?

      min_redeemed_amount = AffiliatePayment::MINIMUM_REDEEM_AMOUNT[currency_code]
      return unless record.redeemed_amount.to_f < min_redeemed_amount

      record.errors.add :redeemed_amount, :invalid_amount
    end

    def validate_overlapped(record)
      return true if record.affiliate.blank?

      # return true if AffiliatePayment.where.not(id: record.id).overlapped_payments(record.affiliate, record.billing_region, record.start_date, record.end_date).empty?

      return true if AffiliatePayment.where.not(id: record.id).overlapped_payments(record.affiliate, 'all', record.start_date, record.end_date).empty?

      record.errors.add :start_date, :overlapped
    end
  end
end
