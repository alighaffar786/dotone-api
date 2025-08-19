module Downloadable
  extend ActiveSupport::Concern

  included do
    # Acessor to pass any meta information accessible
    # for each record during download, such as current
    # currency code
    attr_accessor :download_meta
  end

  def download_meta_currency_code
    (download_meta || {})[:currency_code]
  end

  def download_meta_locale
    (download_meta || {})[:locale]
  end

  def download_meta_time_zone
    (download_meta || {})[:time_zone]
  end

  def download_meta_owner
    (download_meta || {})[:owner]
  end

  module ClassMethods
    include ActionView::Helpers::NumberHelper
    include DotOne::I18n

    def generate_download_notes(params = {})
      notes = DotOne::DownloadNotes.create(self, params)
      notes.generate
    end

    def download_file_type
      name
    end

    def download_name
      name.titleize
    end

    def download_columns
      column_names
    end

    def download_valid_columns
      (column_names | download_formatters.keys).map(&:to_sym)
    end

    # NOTE: Please don't fatten model logics for download column purposes.
    # Please use this method
    def download_formatters
      network_formatter = Proc.new { |record, ability|
        network = record.is_a?(Network) ? record : record.network

        next unless network

        if ability.can?(:manage, network)
          network.id_with_name
        else
          network.id
        end
      }
      affiliate_formatter = Proc.new { |record, ability|
        affiliate = record.is_a?(Affiliate) ? record : record.affiliate

        next unless affiliate

        if ability.can?(:manage, affiliate)
          affiliate.id_with_name
        else
          affiliate.id
        end
      }

      {
        affiliate: affiliate_formatter,
        affiliate_id: affiliate_formatter,
        network: network_formatter,
        network_id: network_formatter,
        image_creative_id: -> (record) { record.image_creative&.id_with_name },
        ip_country: -> (record) { Country.t_name(record.ip_country, record.download_meta_locale) },
        offer_id: -> (record) { record.offer&.id_with_name(record.download_meta_locale) },
        offer_variant_id: -> (record) { record.offer_variant&.t_name(record.download_meta_locale) },
        text_creative_id: -> (record) { record.text_creative&.id_with_name },
      }
    end

    def generate_download_headers(*_args)
      columns = (block_given? ? yield : download_columns).to_a.map(&:to_sym)

      headers = []

      columns.each do |column|
        if download_valid_columns.include?(column) || new.respond_to?(column)
          headers << [column, download_column_t(column)]
        end
      end

      headers
    end

    # NOTE: There's a naming convention to download columns
    # Please follow through with it here or on client applications
    # So that, we don't fatten model logics and translations to fit client applications
    # ex: affiliate_stat.true_pay column name would be exactly true_pay (no payouts aliases etc)
    # ex: network.billing_email column name would be network_billing_email
    def download_column_t(column, **options)
      name_to_use = name
      name_to_use = 'AffiliateStat' if AffiliateStat::PARTITIONS.map(&:name).include?(name)
      download_t("#{name_to_use.underscore}.#{column}", **options)
    rescue StandardError
      column.to_s.titleize
    end

    def record_t(record, method_t = :st)
      return unless value = yield.presence

      send(method_t, value, locale: record.download_meta_locale, raise: true) rescue value.to_s.titleize
    end

    def download_predefined_t(record, column, model = nil)
      return unless value = record.send(column).presence

      table_name_to_use = table_name
      table_name_to_use = 'affiliate_stats' if AffiliateStat::PARTITIONS.map(&:table_name).include?(table_name)

      prefix ||= "#{model || table_name_to_use.singularize.underscore}.#{column}"

      if value.is_a?(Array)
        value.map do |v|
          predefined_t("#{prefix}.#{v}", locale: record.download_meta_locale) rescue v.to_s.titleize
        end
          .join(', ')
      else
        predefined_t("#{prefix}.#{value}", locale: record.download_meta_locale) rescue value.to_s.titleize
      end
    end

    def download_date_local(record, column)
      record.send("#{column}_local", record.download_meta_time_zone).try(:strftime, '%Y-%m-%d')
    end
  end
end
