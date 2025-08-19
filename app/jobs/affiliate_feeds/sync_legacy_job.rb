# frozen_string_literal: true

class AffiliateFeeds::SyncLegacyJob < MaintenanceJob
  def perform
    feeds = AffiliateFeed
      .where(id: OwnerHasTag.where(affiliate_tag_id: AffiliateTag.where(tag_type: 'Feed Role')).select(:owner_id))
      .where('updated_at > ?', 2.days.ago)

    roles = OwnerHasTag
      .joins(:affiliate_tag)
      .where(owner_type: 'AffiliateFeed', owner_id: feeds, affiliate_tags: { tag_type: 'Feed Role' })
      .pluck(:owner_id, :name)
      .to_h

    feed_types = OwnerHasTag
      .joins(:affiliate_tag)
      .where(owner_type: 'AffiliateFeed', owner_id: feeds, affiliate_tags: { tag_type: 'Feed Type' })
      .pluck(:owner_id, :name)
      .to_h

    feeds.find_each do |feed|
      role = roles[feed.id]
      feed_type = feed_types[feed.id]

      next unless role

      role, country_ids = if role == 'Advertiser Announcement'
        [AffiliateFeed.role_network, []]
      else
        country_ids = (Country.joins(:offers).where(offers: { id: feed.content_offer_ids }).ids + feed.country_ids).uniq

        [AffiliateFeed.role_affiliate, country_ids]
      end

      catch_exception { feed.update!(role: role, feed_type: feed_type, country_ids: country_ids) }
    end
  end
end
