class Affiliates::Affiliate::PaymentInfoSerializer < Base::AffiliateSerializer
  attributes :id, :tax_filing_country, :tax_filing_country_id, :business_entity, :ssn_ein,
    :legal_resident_address, :local_tax_filing?, :us_tax_filing?, :front_of_id_url, :back_of_id_url,
    :bank_booklet_url, :tax_form_url, :valid_id_url

  has_one :affiliate_application
end
