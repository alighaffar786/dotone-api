class Affiliates::AffiliatePaymentInfoSerializer < Base::AffiliatePaymentInfoSerializer
  attributes :id, :status, :preferred_currency, :preferred_currency_name, :preferred_currency_id, :payment_type,
    :bank_name, :payee_name, :bank_identification, :bank_address, :branch_name, :branch_identification, :iban,
    :routing_number, :account_number, :paypal_email_address, :branch_key

  has_one :affiliate, serializer: Affiliates::Affiliate::PaymentInfoSerializer
end
