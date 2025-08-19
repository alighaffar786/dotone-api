module DotOne::ApiClient::CreditCardApi::Card
  class Stripe < Base
    def assign_attributes
      credit_card.assign_attributes(
        card_token: stripe.card.id,
        last_4_digits: stripe.card.last4,
        brand: stripe.card.brand,
        unique_identifier: stripe.card.fingerprint,
        exp_month: stripe.card.exp_month,
        exp_year: stripe.card.exp_year,
      )
      link_to_customer
    end

    def link_to_customer
      ::Stripe::Customer.create_source(
        payment_gateway.customer_token,
        { source: stripe.id },
      )
    # more info of the Exception https://www.rubydoc.info/gems/stripe/Stripe/InvalidRequestError
    rescue ::Stripe::InvalidRequestError => e
      if e.json_body[:error][:code] == 'resource_missing' && e.json_body[:error][:param] == 'customer'
        # https://stripe.com/docs/error-codes#resource-missing
        payment_gateway.create_token
        payment_gateway.save
        link_to_customer

        return
      end

      Rails.logger.error e
      credit_card.errors.add(:base, 'Unexpected error while linking to customer')
    end

    def unlink
      ::Stripe::Customer.delete_source(
        network.customer_token,
        credit_card.card_token,
      )
    rescue ::Stripe::InvalidRequestError => e
      Rails.logger.error e
    end

    def default!
      ::Stripe::Customer.update(
        network.customer_token,
        { default_source: credit_card.card_token },
      )
    rescue ::Stripe::InvalidRequestError => e
      Rails.logger.error e
    end

    private

    def stripe
      @stripe ||= retrieve
    rescue ::Stripe::InvalidRequestError => e
      Rails.logger.error e
      raise_invalid_card
    end

    def retrieve
      ::Stripe::Token.retrieve(credit_card.token)
    end
  end
end
