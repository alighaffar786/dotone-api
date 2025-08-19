module NetworkOfferHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      super { columns }
    end

    def download_formatters
      super.merge(
        affiliate_logs: -> (record) {
          record.latest_logs.map(&:notes).join("\n")
        },
        affiliate_share: -> (record) {
          range = record.calculate_affiliate_share_range(record.download_meta_owner)
          "#{range.join(' - ')}%" if range.present?
        },
        affiliate_pay: -> (record) {
          range = record.calculate_affiliate_pay_range(record.download_meta_owner, record.download_meta_currency_code)
          "(#{record.download_meta_currency_code}) #{range.join(' - ')}" if range.present?
        },
        attribution_type: -> (record) {
          download_predefined_t(record, :attribution_type)
        },
        brand_image_url: -> (record) {
          record.brand_image&.cdn_url
        },
        brand_image_small_url: -> (record) {
          record.brand_image_small&.cdn_url
        },
        categories: -> (record) {
          record.categories
            .map { |cat| cat.t_name(record.download_meta_locale) }
            .join(', ')
        },
        click_volume: -> (record) {
          report = DotOne::Reports::OfferClickVolume.new(record.download_meta || {})
          epcs = report.generate_epc
          "#{epcs[record.id].to_f} EPC"
        },
        countries: -> (record) {
          record.countries
            .map { |country| country.t_name(record.download_meta_locale) }
            .join(', ')
        },
        group_tags: -> (record) {
          record.group_tags
            .map { |tag| tag.t_name(record.download_meta_locale) }
            .join(', ')
        },
        has_product_api: -> (record) {
          tt(record.has_product_api? ? 'boolean_yes' : 'boolean_no', locale: record.download_meta_locale)
        },
        media_restrictions: -> (record) {
          record.media_restrictions
            .map { |restriction| restriction.t_name(record.download_meta_locale) }
            .join(', ')
        },
        original_currency: -> (record) {
          record.default_conversion_step&.true_currency&.code
        },
        published_date: -> (record) {
          download_date_local(record, :published_date)
        },
        true_pay: -> (record) {
          range = record.calculate_true_pay_range(record.download_meta_currency_code)
          "(#{record.download_meta_currency_code}) #{range.join(' - ')}" if range.present?
        },
        true_share: -> (record) {
          range = record.calculate_true_share_range
          "#{range.join(' - ')}%" if range.present?
        },
        status: -> (record) {
          record_t(record) { record.status }
        },
        track_device: -> (record) {
          download_predefined_t(record, :track_device)
        },
      )
    end
  end
end
