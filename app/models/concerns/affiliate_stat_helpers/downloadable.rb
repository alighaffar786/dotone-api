module AffiliateStatHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DEFAULT_BASIC_COLUMNS = [
    :transaction_id,
    :recorded_at,
    :captured_at,
    :published_at,
    :converted_at,
    :offer_id,
    :ip_address,
  ]

  BASIC_COLUMNS = {
    affiliate: -> (_user) {
      DEFAULT_BASIC_COLUMNS
    },
    network: -> (_user) { [] },
    owner: -> (user) {
      ability = Ability.new(user)

      if ability.can?(:read, Affiliate)
        DEFAULT_BASIC_COLUMNS + [:affiliate_id, :affiliate_full_name, :affiliate_status]
      else
        DEFAULT_BASIC_COLUMNS + [:affiliate_id]
      end
    },
  }

  CONVERSION_DATA_COLUMNS = {
    affiliate: [
      :order_number,
      :order_total_for_affiliate,
      :step_label,
      :affiliate_pay,
      :approval,
    ],
    owner: [
      :order_number,
      :order_total,
      :step_label,
      :true_pay,
      :affiliate_pay,
      :calculated_margin,
      :approval,
    ],
  }

  module ClassMethods
    def download_name
      'Transactions'
    end

    def download_columns(**options)
      user = options[:user]
      user_role = user&.generic_role

      if user_role && user_role != :network
        BASIC_COLUMNS[user_role].call(user).to_a +
          (options[:include_conversion_data] ? CONVERSION_DATA_COLUMNS[user_role].to_a : [])
      else
        DEFAULT_BASIC_COLUMNS
      end
    end

    def generate_download_headers(columns = [], **options)
      # NOTE: Looks like valid column filter is removed.
      # Code wil break if user request an invalid column.
      super do
        (download_columns(**options) | columns.to_a.map(&:to_sym))
      end
    end

    def download_formatters
      super.merge(
        transaction_id: -> (record) { record.original_id },
        order_step_label: -> (record) { record.step_label.presence || record.copy_order&.step_label },
        order_step_name: -> (record) { record.step_name.presence || record.copy_order&.step_name },
        order_number: -> (record) { record.order_number.presence || record.copy_order&.order_number },
        order_days_return: -> (record) {
          return unless order = record.copy_order

          order.days_return_past_due? ? 'Please confirm order' : order.days_return - order.days_since_order
        },
        order_real_total: -> (record) {
          obj = record.copy_order || record

          number_to_currency(obj.real_total, unit: obj.true_currency_code, format: '%u %n')
        },
        skip_api_refresh: -> (record) {
          locale = record.download_meta_locale
          record.skip_api_refresh? ? st('Yes', locale: locale) : st('No', locale: locale)
        },
        approval: -> (record) {
          record_t(record) { record.approval }
        },
        offer_status: -> (record) {
          return unless offer = record.offer

          record_t(record) { offer.status }
        },
        affiliate_status: -> (record) {
          return unless affiliate = record.affiliate

          record_t(record) { affiliate.status }
        },
        network_status: -> (record) {
          return unless network = record.network

          record_t(record) { network.status }
        },
        postback_stats: -> (record) {
          return unless postback_stats = record.postback_stats

          postback_stats.map { |k, v| "#{k}: #{v}" }.join(' | ')
        },
        ip_address: -> (record) {
          if record.download_meta_owner.is_a?(AffiliateUser)
            record.ip_address
          else
            record.masked_ip_address
          end
        },
      )
    end
  end
end
