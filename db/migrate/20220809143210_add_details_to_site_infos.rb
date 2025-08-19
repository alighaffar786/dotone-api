class AddDetailsToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :followers_count, :integer
    add_column :site_infos, :media_count, :integer
    add_column :site_infos, :last_media_posted_at, :datetime
    add_column :site_infos, :instagram_id, :string
    add_column :site_infos, :instagram_username, :string
  end
end
