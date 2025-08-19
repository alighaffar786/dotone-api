module DotOne::ApiClient::CreditCardApi::Card
  class TapPay < Base
    def assign_attributes
      retrieve_tap_pay
      credit_card.assign_attributes(
        unique_identifier: @tap_pay['card_identifier'],
        card_token: @tap_pay.dig('card_secret', 'card_token'),
        card_key: @tap_pay.dig('card_secret', 'card_key'),
        last_4_digits: @tap_pay.dig('card_info', 'last_four'),
        exp_month: (@tap_pay.dig('card_info', 'expiry_date').to_s)[4..5],
        exp_year: (@tap_pay.dig('card_info', 'expiry_date').to_s)[0..3],
        brand: CARD_TYPES[@tap_pay.dig('card_info', 'type')],
      )
    end

    def unlink
      ::TapPay::Card.remove(
        card_key: credit_card.card_key,
        card_token: credit_card.card_token,
      ).tap do |res|
        return res if res['status'] == 0

        Rails.logger.error StandardError.new(res)
      end
    end

    def default!; end

    private

    def bind_params
      {
        prime: credit_card.token,
        merchant_id: DEFAULT_MERCHANT,
        currency: currency_code,
        cardholder: {
          phone_number: network.contact_phone,
          name: network.name,
          email: network.email,
        },
      }
    end

    def retrieve_tap_pay
      @tap_pay = ::TapPay::Card.bind(bind_params).tap do |res|
        if res['status'] == 0
          res
        else
          Rails.logger.error StandardError.new(res)
          raise_invalid_card
        end
      end
    end
  end
end
