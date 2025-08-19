class EventOffers::SyncCategoryJob < MaintenanceJob
  def perform
    categories = AffiliateTag.event_media_categories.index_by(&:name)

    EventInfo
      .left_joins(:event_media_category)
      .where(affiliate_tags: { id: nil })
      .find_each do |event_info|
        event_tag = OwnerHasTag.joins(:affiliate_tag)
          .where(owner: event_info, affiliate_tags: { tag_type: AffiliateTag.tag_type_media_category })
          .where.not(affiliate_tags: { parent_category_id: nil })
          .first

        next if event_tag.blank?

        if (category = categories[event_tag.affiliate_tag.name])
          event_info.update(event_media_category: category)
        end
      end
  end
end
