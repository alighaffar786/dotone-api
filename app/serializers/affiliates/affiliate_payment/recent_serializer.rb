class Affiliates::AffiliatePayment::RecentSerializer < Base::AffiliatePaymentSerializer
  attributes :id, :start_date, :end_date, :preferred_currency, :amount, :status, :paid_date
end
