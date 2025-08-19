class AddRepublishedAtToAffiliateFeeds < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_feeds, :republished_at, :datetime
  end
end
