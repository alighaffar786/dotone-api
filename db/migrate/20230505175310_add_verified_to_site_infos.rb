class AddVerifiedToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :verified, :boolean, default: false
  end
end
