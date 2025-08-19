class AddFeedTypeColumnsToAffiliateFeeds < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_feeds, :role, :string
    add_column :affiliate_feeds, :feed_type, :string

    feed_types = OwnerHasTag
      .joins(:affiliate_tag)
      .where(owner_type: 'AffiliateFeed', affiliate_tags: { tag_type: 'Feed Type' })
      .pluck(:owner_id, :name)
      .to_h

    OwnerHasTag.where(affiliate_tag_id: AffiliateTag.where(tag_type: 'Feed Role')).preload(:affiliate_tag).find_each do |owner_has_tag|
      feed = AffiliateFeed.find(owner_has_tag.owner_id)
      tag = owner_has_tag.affiliate_tag

      feed.role = if tag.name == 'Advertiser Announcement'
        AffiliateFeed.role_network
      else
        AffiliateFeed.role_affiliate
      end

      feed.feed_type = feed_types[feed.id]
      feed.save!
    end
  end
end
