module Chargeable
  extend ActiveSupport::Concern

  included do
    has_many :payment_gateways, dependent: :nullify
    has_many :credit_cards, through: :payment_gateways
    has_many :charges, dependent: :nullify
  end

  def charge(args = {})
    charges.create(amount: args[:amount], credit_card_id: args[:credit_card_id])
  end

  def payment_gateway_type
    if country.iso_2_country_code == 'TW'
      :tap_pay
    else
      :stripe
    end
  end

  def customer_token
    payment_gateways.stripe.first&.customer_token
  end
end
