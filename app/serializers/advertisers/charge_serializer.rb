class Advertisers::ChargeSerializer < ApplicationSerializer
  attributes :id, :network_id, :credit_card_id, :amount, :currency_code, :status, :is_captured, :amount_captured,
    :is_refunded, :amount_refunded, :created_at, :updated_at
end
