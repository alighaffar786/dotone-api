module DotOne::ApiClient::CreditCardApi::Charge
  class TapPay < Base
    STATUSES = {
      'Success' => 'success',
    }.freeze

    def assign_attributes
      charge_tap_pay

      charge.assign_attributes(
        is_captured: true,
        amount_captured: charge.amount,
        status: STATUSES[@tap_pay['msg']],
        response: @tap_pay.as_json,
      )
    end

    def charge_tap_pay
      @tap_pay = ::TapPay::Payment.pay_by_token(
        currency: charge.currency_code,
        merchant_id: DotOne::ApiClient::CreditCardApi::Card::Base::DEFAULT_MERCHANT,
        amount: charge.amount,
        details: 'Charge network using card token',
        card_key: charge.credit_card.card_key,
        card_token: charge.credit_card.card_token,
      ).tap do |res|
        if res['status'] == 0
          res
        else
          Rails.logger.error StandardError.new(res)
          error_to_charge
        end
      end
    end
  end
end
