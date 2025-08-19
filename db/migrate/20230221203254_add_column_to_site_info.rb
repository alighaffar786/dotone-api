class AddColumnToSiteInfo < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :refresh_token, :text
  end
end
