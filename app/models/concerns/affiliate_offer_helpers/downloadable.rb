module AffiliateOfferHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  EVENT_DOWNLOAD_COLUMNS = [
    :created_at,
    :affiliate,
    :event,
    :event_status,
    :phone_number,
    :shipping_address,
    :event_shipment_notes,
    :event_supplement_notes,
    :site_info_url,
    :event_draft_url,
    :event_published_url,
    :event_contract_signature,
    :approval_status,
  ]

  module ClassMethods
    def generate_download_headers(columns = [], **options)
      return unless options[:type] == :event

      super { EVENT_DOWNLOAD_COLUMNS }
    end

    def download_formatters
      super.merge(
        event: -> (record) { record.offer&.id_with_name },
        event_status: -> (record) {
          return unless status = record.offer&.status
          predefined_t("offer_variant.status.#{status}", locale: record.download_meta_locale) rescue status.titleize
        },
        shipping_address: -> (record) {
          AffiliateAddress.new(record.shipping_address).full_address_with_country
        },
        site_info_url: -> (record) { record.site_info&.url },
        event_contract_signature: -> (record) {
          [
            record.event_contract_signature,
            record.event_contract_signed_ip_address,
          ].reject(&:blank?).join('|')
        },
        approval_status: -> (record) {
          download_predefined_t(record, :approval_status)
        }
      )
    end
  end
end
