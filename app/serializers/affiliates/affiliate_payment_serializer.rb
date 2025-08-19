class Affiliates::AffiliatePaymentSerializer < Base::AffiliatePaymentSerializer
  attributes :id, :start_date, :end_date, :preferred_currency, :previous_amount, :affiliate_amount,
    :referral_amount, :total_commissions, :redeemable?, :has_invoice?, :payment_info_confirmed?, :redeemed_amount,
    :total_fees, :amount, :balance, :notes, :status, :paid_date, :wire_fee_amount, :tax_fee_amount
end
