class Advertisers::CreditCardSerializer < ApplicationSerializer
  attributes :id, :payment_gateway_id, :card_token, :brand, :last_4_digits, :expire_at, :default
end
