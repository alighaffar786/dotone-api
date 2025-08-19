class Teams::AffiliatePaymentInfoSerializer < Base::AffiliatePaymentInfoSerializer
  class AffiliateSerializer < Teams::Affiliate::MiniSerializer
    attributes :created_at, :ssn_ein, :business_entity, :company?, :tax_filing_country, :tax_filing_country_id,
      :legal_resident_address, :front_of_id_url, :back_of_id_url, :bank_booklet_url, :tax_form_url, :valid_id_url,
      :local_tax_filing?, :us_tax_filing?

    has_one :affiliate_application
    has_many :affiliate_users
  end

  attributes :id, :iban, :preferred_currency, :preferred_currency_name, :preferred_currency_id, :payee_name, :bank_name,
    :bank_identification, :bank_address, :branch_name, :branch_identification, :account_number, :routing_number, :branch_key,
    :paypal_email_address, :payment_type, :affiliate_full_address, :status, :updated_at, :latest_commission, :affiliate_id,
    :confirmed_at

  original_attributes :latest_commission

  has_one :affiliate, serializer: AffiliateSerializer
end
