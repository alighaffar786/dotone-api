class AddAdLinkEnabledToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :ad_link_enabled, :boolean, default: true
  end
end
