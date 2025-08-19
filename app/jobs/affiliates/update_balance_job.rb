# frozen_string_literal: true

class Affiliates::UpdateBalanceJob < EntityManagementJob
  discard_on ActiveRecord::RecordNotFound

  def perform(id)
    affiliate = Affiliate.find(id)

    previous_balance_hash = affiliate.previous_balance
    source_currency_code = previous_balance_hash[:currency_code].presence || Currency.platform_code

    rate = Currency.rate(source_currency_code, affiliate.preferred_currency_code)
    new_current_balance = rate * previous_balance_hash[:amount].to_f

    return if affiliate.current_balance == new_current_balance

    affiliate.current_balance = new_current_balance
    affiliate.save(validate: false)
  end
end
