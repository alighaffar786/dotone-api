module AffiliateHelpers::Downloadable
  extend ActiveSupport::Concern
  include ::Downloadable

  DOWNLOAD_COLUMNS = [
    :affiliate,
    :status,
    :avatar_url,
    :business_entity,
    :gender,
    :birthday,
    :company_name,
    :company_site,
    :contact_info,
    :country,
    :referrer,
    :transaction_affiliate,
    :transaction_subid_1,
    :transaction_subid_2,
    :transaction_subid_3,
    :transaction_subid_4,
    :transaction_subid_5,
    :channel,
    :campaign,
    :created_at,
    :last_request_at,
    :login_count,
    :ranking,
    :experience_level,
    :traffic_quality_level,
    :label,
    :source,
    :media_categories,
    :recruiter,
    :affiliate_users,
    :conversion_count,
    :top_offers,
    :group_tags,
    :affiliate_logs,
  ]

  module ClassMethods
    def download_inactive_columns
      [:current_balance, :last_request_at]
    end

    def generate_download_headers(columns = [], **options)
      user = options[:user]
      ability = Ability.new(user)

      super do
        [:affiliate] | ((ability.can?(:manage, Affiliate) ? DOWNLOAD_COLUMNS + [:site_infos] : DOWNLOAD_COLUMNS) & columns&.map(&:to_sym))
      end
    end

    def download_formatters
      super.merge(
        status: -> (record) { download_predefined_t(record, :status) },
        gender: -> (record) { download_predefined_t(record, :gender) },
        business_entity: -> (record) { download_predefined_t(record, :business_entity) },
        company_site: -> (record) { record.affiliate_application&.company_site },
        contact_info: -> (record) {
          data = [
            record.email,
            record.phone_number,
            record.messenger_service.present? && record.messenger_id.present? ? "(#{record.messenger_service}) #{record.messenger_id}" : nil
          ]

          data.reject(&:blank?).join("\n")
        },
        country: -> (record) { record.country&.t_name(record.download_meta_locale) },
        referrer: -> (record) { record.referrer&.id_with_name },
        transaction_affiliate: -> (record) { record.transaction_affiliate&.id_with_name },
        channel: -> (record) { record.channel&.id_with_name },
        campaign: -> (record) { record.campaign&.id_with_name },
        created_at: -> (record) { record.created_at.strftime('%Y-%m-%d') },
        last_request_at: -> (record) { record.last_request_at&.strftime('%Y-%m-%d') },
        label: -> (record) { download_predefined_t(record, :label) },
        source: -> (record) { download_predefined_t(record, :source) },
        media_categories: -> (record) { record.media_categories.map.map { |mc| mc.t_name(record.download_meta_locale) }.join("\n") },
        site_infos: -> (record) { record.site_infos.map(&:url).reject(&:blank?).join("\n") },
        recruiter: -> (record) { record.recruiter&.id_with_name },
        affiliate_users: -> (record) { record.affiliate_users.map(&:full_name).join("\n") },
        top_offers: -> (record) { record.top_offers.map(&:id_with_name).join("\n") },
        group_tags: -> (record) { record.group_tags.map { |gt| gt.t_name(record.download_meta_locale) }.join("\n") },
        affiliate_logs: -> (record) { record.latest_logs.map(&:notes).join("\n") },
        experience_level: -> (record) { download_predefined_t(record, :experience_level) },
        traffic_quality_level: -> (record) { download_predefined_t(record, :traffic_quality_level) },
        ranking: -> (record) { download_predefined_t(record, :ranking) },
      )
    end
  end
end
