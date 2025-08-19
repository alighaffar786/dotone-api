module DotOne::ApiClient::CreditCardApi::Charge
  class Stripe < Base
    STATUSES = {
      'succeeded' => 'success',
    }.freeze

    def assign_attributes
      charge.assign_attributes(
        is_captured: stripe.captured,
        amount_captured: stripe.amount_captured,
        is_refunded: stripe.refunded,
        amount_refunded: stripe.amount_refunded,
        status: STATUSES[stripe.status],
        response: stripe,
      )
    end

    def stripe
      @stripe ||= ::Stripe::Charge.create(
        customer: network.customer_token,
        amount: charge.amount,
        source: charge.credit_card.card_token,
        currency: charge.currency_code,
      )
    rescue ::Stripe::InvalidRequestError => e
      Rails.logger.error e
      error_to_charge
    end
  end
end
