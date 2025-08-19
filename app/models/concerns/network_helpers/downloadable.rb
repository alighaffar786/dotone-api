module NetworkHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DOWNLOAD_COLUMN_MAP = {
    id: [:id, :name, :brands, :country],
    date: [:created_at, :profile_updated_at, :published_date],
    contact_info: [:contact_title, :contact_name, :contact_email, :contact_phone],
    company_info: [:category_groups, :company_url],
    contact_list: [:contact_lists],
    marketing: [:channel, :campaign],
    affiliate_user: [:affiliate_users, :recruiter],
    billing: [:billing_currency, :billing_region, :subscription],
    transaction: [:transaction_affiliate, :transaction_subid_1, :transaction_subid_2, :transaction_subid_3, :transaction_subid_4, :transaction_subid_5],
    affiliate_logs: [:affiliate_logs],
  }

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      columns = columns&.map(&:to_sym)
      mapped_columns = DOWNLOAD_COLUMN_MAP[:id].flatten + DOWNLOAD_COLUMN_MAP.slice(*columns).values.flatten
      requested_columns = columns - DOWNLOAD_COLUMN_MAP.keys
      super { (mapped_columns + requested_columns).uniq }
    end

    def download_formatters
      super.merge(
        status: -> (record) { download_predefined_t(record, :status) },
        affiliate_logs: -> (record) { record.latest_logs&.map(&:notes).join("\n") },
        country: -> (record) { record.country&.t_name(record.download_meta_locale) },
        contact_lists: -> (record) { record.contact_lists&.map(&:full_name_with_email)&.join("\n") },
        affiliate_users: -> (record) { record.affiliate_users&.map(&:id_with_name).join("\n") },
        category_groups: -> (record) { record.category_groups&.map { |group| group.t_name(record.download_meta_locale) }.join("\n") },
        brands: -> (record) { record.brands&.map(&:to_s)&.join("\n") },
        recruiter: -> (record) { record.recruiter&.id_with_name },
        channel: -> (record) { record.channel&.id_with_name },
        campaign: -> (record) { record.campaign&.id_with_name },
        sales_pipeline: -> (record) { download_predefined_t(record, :sales_pipeline, 'network') },
        payment_term: -> (record) { download_predefined_t(record, :payment_term, 'network') },
        billing_currency: -> (record) { record.billing_currency&.code },
        billing_region: -> (record) { AffiliatePayment::BILLING_REGIONS[record.billing_region] },
        transaction_affiliate: -> (record) { record.transaction_affiliate&.id_with_name },
      )
    end
  end
end
