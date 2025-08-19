namespace :wl do
  namespace :event_offer do
    namespace :event_info do
      task convert_media_category_to_event_media_category: :environment do
        EventOffer.find_each do |event|
          next if event.event_info.event_media_category.present?
          next if event.event_info.blank?

          event_tag = OwnerHasTag.joins(:affiliate_tag)
            .where(owner: event.event_info, affiliate_tags: { tag_type: AffiliateTag.tag_type_media_category })
            .where.not(affiliate_tags: { parent_category_id: nil })
            .first

          next if event_tag.blank?

          event_media_category = AffiliateTag.event_media_categories.find_by(name: event_tag.affiliate_tag.name)

          next if event_media_category.blank?

          event.event_info.update(event_media_category: event_media_category)
        end
      end
    end
  end
end
