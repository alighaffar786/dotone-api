class ChangeAppearanceToAppearanceInSiteInfos < ActiveRecord::Migration[6.1]
  def up
    add_column :site_infos, :appearances, :json, array: true
    remove_column :site_infos, :appearance
  end

  def down
    add_column :site_infos, :appearance, :string
    remove_column :site_infos, :appearances
  end
end
