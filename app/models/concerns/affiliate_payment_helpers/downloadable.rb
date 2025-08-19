module AffiliatePaymentHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DOWNLOAD_COLUMNS = [
    :affiliate_id,
    :payment_period,
    :paid_date,
    :ssn_ein,
    :business_entity,
    :id,
    :affiliate,
    :affiliate_users,
    :company_name,
    :payee_name,
    :previous_amount,
    :referral_amount,
    :affiliate_amount,
    :total_commissions,
    :redeemed_amount,
    :non_redeemed_amount,
    :tax_fee_amount,
    :post_tax_payment_amount,
    :wire_fee_amount,
    :net_payment_amount,
    :taxable_payment,
    :payment_info_status,
    :status,
    :payment_type,
    :legal_resident_address,
    :tax_filing_country,
    :bank_name,
    :branch_name,
    :bank_identification,
    :branch_identification,
    :routing_number,
    :account_number,
    :bank_address,
    :iban,
    :paypal_email_address,
    :preferred_currency,
    :mailing_country,
    :notes,
  ]

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      super { DOWNLOAD_COLUMNS }
    end

    def download_formatters
      super.merge(
        affiliate_id: -> (record) { record.affiliate_id },
        paid_date: -> (record) { record.paid_date&.strftime('%Y-%m-%d') },
        affiliate_users: -> (record) { record.affiliate_users.map(&:full_name).join(', ') },
        business_entity: -> (record) { predefined_t("affiliate.business_entity.#{record.business_entity}") },
        payment_info_status: -> (record) { predefined_t("affiliate_payment_info.status.#{record.payment_info_status}") },
        status: -> (record) { download_predefined_t(record, :status) },
        tax_filing_country: -> (record) {
          return unless record.tax_filing_country

          predefined_t("country.name.#{record.tax_filing_country}", raise: false, default: record.tax_filing_country)
        },
        payment_period: -> (record) { [record.start_date, record.end_date].join(' - ') },
      )
    end
  end
end
