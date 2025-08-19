class Teams::AffiliatePaymentSerializer < Base::AffiliatePaymentSerializer
  attributes :id, :paid_date, :start_date, :end_date, :previous_amount, :referral_amount, :affiliate_amount, :total_commissions,
    :redeemed_amount, :total_fees, :amount, :tax_filing_country, :payment_info_status, :status, :conversion_file_url, :business_entity,
    :preferred_currency, :wire_fee_amount, :tax_fee_amount, :affiliate_id, :payment_type, :balance,
    :payee_name, :bank_name, :bank_identification, :bank_address, :branch_name,
    :branch_identification, :iban, :routing_number, :account_number, :address1, :address2, :zip_code,
    :city, :state, :country_id, :paypal_email_address, :notes, :has_invoice, :billing_region

  original_attributes :start_date, :end_date, :paid_date

  has_many :affiliate_users, serializer: Teams::AffiliateUser::MiniSerializer

  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer
end
