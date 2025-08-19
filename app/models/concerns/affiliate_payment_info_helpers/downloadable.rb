module AffiliatePaymentInfoHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DOWNLOAD_AFFILIATE_COLUMNS = [
    :affiliate_id,
    :company_name,
    :affiliate_email,
    :phone_number,
    :affiliate_created_at,
    :ssn_ein,
  ].freeze

  DOWNLOAD_BANK_COLUMNS = [
    :bank_identification,
    :bank_name,
    :bank_address,
    :branch_identification,
    :branch_name,
  ].freeze

  DOWNLOAD_ACCOUNT_COLUMNS = [
    :iban,
    :routing_number,
    :account_number,
    :paypal_email_address,
  ].freeze

  DOWNLOAD_COLUMNS = [
    :updated_at,
    *DOWNLOAD_AFFILIATE_COLUMNS,
    :affiliate_users,
    :status,
    :payment_type,
    :payee_name,
    :legal_resident_address,
    :affiliate_full_address,
    :tax_filing_country,
    *DOWNLOAD_BANK_COLUMNS,
    *DOWNLOAD_ACCOUNT_COLUMNS,
    :preferred_currency,
    :latest_commission,
  ].freeze

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      super do
        DOWNLOAD_COLUMNS & columns.inject([]) do |cols, col|
          case col
          when :affiliate
            cols.concat(DOWNLOAD_AFFILIATE_COLUMNS)
          when :bank
            cols.concat(DOWNLOAD_BANK_COLUMNS)
          when :account
            cols.concat(DOWNLOAD_ACCOUNT_COLUMNS)
          else
            cols.push(col)
          end
        end
      end
    end

    def download_formatters
      super.merge(
        status: -> (record) { download_predefined_t(record, :status) },
        payment_type: -> (record) { download_predefined_t(record, :payment_type) },
        affiliate_users: -> (record) { record.affiliate_users.map(&:full_name).join("\n") },
        affiliate_created_at: -> (record) { record.created_at.strftime('%Y-%m-%d') },
      )
    end
  end
end
