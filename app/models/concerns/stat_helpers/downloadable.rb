module StatHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  module ClassMethods
    def download_file_type
      name
    end

    def download_columns(user_role)
      if user_role == :affiliate
        DotOne::Reports::Affiliates::StatSummary.downloaded_columns
      elsif user_role == :owner
        DotOne::Reports::AffiliateUsers::StatSummary.downloaded_columns
      else
        DotOne::Reports::Networks::StatSummary.downloaded_columns
      end
    end

    def generate_download_headers(columns = [], **options)
      user_role = options[:user]&.generic_role

      (download_columns(user_role) & columns.map(&:to_sym)).map do |column|
        [column, download_summary_column_t(column, currency: options[:currency_code], role: user_role)]
      end
    end

    def generate_download_performance_headers
      [:affiliate, :site_info_urls, :clicks, :captured].map do |column|
        [column, download_column_t(column)]
      end
    end

    def download_formatters
      super.merge(
        site_info_urls: -> (record) { record.affiliate&.site_infos&.map(&:url)&.join("\n") },
        media_categories: -> (record) { record.affiliate&.media_categories&.map { |mc| mc.t_name(record.download_meta_locale) }&.join("\n") },
        contact_lists: -> (record) { record.network&.contact_lists&.map(&:full_name_with_email)&.join("\n") },
        network_contact_email: -> (record) { record.network&.contact_email },
        network_status: -> (record) {
          return unless status = record.network&.status.presence

          predefined_t("network.status.#{status}", locale: record.download_meta_locale) rescue status.titleize
        },
        network_billing_email: -> (record) { record.network&.billing_email },
        network_payment_term: -> (record) {
          return unless payment_term = record.network&.payment_term.presence

          predefined_t("network.payment_term.#{payment_term}", locale: record.download_meta_locale) rescue payment_term.titleize
        },
        network_payment_term_days: -> (record) { record.network&.payment_term_days },
        network_universal_number: -> (record) { record.network&.universal_number },
        network_country: -> (record) { record.network&.country&.t_name(record.download_meta_locale) },
      )
    end

    def download_summary_formatters
      download_formatters.merge(DotOne::Reports::StatSummary.download_formatters)
    end

    def download_summary_column_t(column, **options)
      role = options.delete(:role) || :owner
      t("download_summary_columns.models.stat.#{role}.#{column}", raise: true, **options)
    rescue StandardError
      column.to_s.titleize
    end
  end
end
