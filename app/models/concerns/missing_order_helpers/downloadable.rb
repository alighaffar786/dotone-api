module MissingOrderHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  included do
    alias_method :download_meta_payout_currency, :download_meta_currency_code
    alias_method :download_meta_order_total_currency, :download_meta_currency_code
  end

  module ClassMethods
    def download_name
      'Order Inquiries'
    end

    def generate_download_headers(columns = [], **options)
      super do
        {
          payouts: :download_meta_payout_currency,
          order_total: :download_meta_order_total_currency,
        }.each_pair do |col, new_column|
          col_index = columns.index(col.to_s)
          columns.insert(col_index, new_column) if col_index
        end

        columns
      end
    end

    def download_formatters
      super.merge(
        offer: -> (record) { record.offer&.id_with_name },
      )
    end
  end
end
