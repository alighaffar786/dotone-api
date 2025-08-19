# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class CommissionBalance < Base
    def generate
      super do
        {
          current_credit_balance: current_balance,
          current_estimated_commissions: estimated_commissions,
          estimated_balance: estimated_balance,
          pending_conversions: pending_conversions_count,
          balance_last_update: balance_last_update,
        }
      end
    end

    def current_balance
      @current_balance ||= to_current_currency(Currency.platform_code, network.current_balance)
    end

    def estimated_commissions
      return @estimated_commissions if @estimated_commissions.present?

      date_range = time_zone.local_range(:this_month)

      @estimated_commissions ||= stats
        .between(*date_range, :converted_at, time_zone)
        .stat([], [:total_true_pay], currency_code: currency_code, time_zone: time_zone, user_role: :network)[0]
        .total_true_pay
        .to_f
    end

    def estimated_balance
      @estimated_balance ||= (current_balance - estimated_commissions).round(2)
    end

    def pending_conversions_count
      date_range = [180.days.ago, Time.now]

      @pending_conversions_count ||= stats
        .has_conversions
        .pending
        .between(*date_range, :captured_at, time_zone)
        .count
    end

    def balance_last_update
      @balance_last_update ||= network.current_balance_item&.created_at
    end
  end
end
