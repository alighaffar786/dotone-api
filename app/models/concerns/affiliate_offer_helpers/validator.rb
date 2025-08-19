module AffiliateOfferHelpers::Validator
  class SiteInfoRequired < ActiveModel::Validator
    def validate(record)
      must_have_site_info(record)
      must_have_valid_media_category(record)
    end

    private

    def must_have_site_info(record)
      offer = record.offer
      site_infos = record.affiliate&.site_infos

      return true unless offer.placement_needed?
      return true if site_infos&.any?

      record.errors.add :site_info_id, record.errors.generate_message(:affiliate_id, :no_site_info)
    end

    def must_have_valid_media_category(record)
      offer = record.offer
      affiliate = record.affiliate

      return if offer.network_offer? || !offer.event_info.is_affiliate_requirement_needed? ||
        offer.event_info.media_category.blank? || affiliate.blank? ||
        record.site_info.media_category == offer.event_info.media_category

      record.errors.add :site_info_id, record.errors.generate_message(:affiliate_id, :no_site_info)
    end
  end
end
