module AdvertiserBalanceHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DOWNLOAD_COLUMNS = [
    :id,
    :updated_at,
    :recorded_at,
    :network_id,
    :credit,
    :debit,
    :sales_tax,
    :network_sales_tax,
    :invoice_number,
    :invoice_amount,
    :invoice_date,
    :record_type,
    :original_credit,
    :original_debit,
    :original_sales_tax,
    :original_invoice_amount,
    :notes,
  ]

  REMAINING_DOWNLOAD_COLUMNS = [
    :network,
    :final_balance,
    :pending_payout,
    :published_payout,
    :remaining_balance,
  ]

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      super { DOWNLOAD_COLUMNS & columns.map(&:to_sym) }
    end

    def generate_remaining_download_headers
      REMAINING_DOWNLOAD_COLUMNS.map do |column|
        [column, download_column_t(column)]
      end
    end

    def download_pending_payouts
      @download_pending_payouts ||= Stat.network_pending_payouts
    end

    def download_published_payouts
      @download_published_payouts ||= Stat.network_published_payouts
    end

    def download_formatters
      super.merge(
        network_sales_tax: -> (record) { record.network.sales_tax&.to_f },
        original_credit: -> (record) { record.credit&.to_f },
        original_debit: -> (record) { record.debit&.to_f },
        original_sales_tax: -> (record) { record.sales_tax&.to_f },
        original_invoice_amount: -> (record) { record.invoice_amount&.to_f },
        record_type: -> (record) { download_predefined_t(record, :record_type) },
        pending_payout: -> (record) {
          download_pending_payouts[record.network_id]&.pending_true_pay.to_f.round(2)
        },
        published_payout: -> (record) {
          download_published_payouts[record.network_id]&.published_true_pay.to_f.round(2)
        },
        remaining_balance: -> (record) {
          pending = download_pending_payouts[record.network_id]&.pending_true_pay.to_f.round(2)
          published = download_published_payouts[record.network_id]&.published_true_pay.to_f.round(2)

          record.final_balance - pending - published
        }
      )
    end
  end
end
