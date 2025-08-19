class RemoveRefreshTokenAndAddErrorsToSiteInfos < ActiveRecord::Migration[6.1]
  def up
    remove_column :site_infos, :refresh_token
    add_column :site_infos, :error_details, :text
  end

  def down
    add_column :site_infos, :refresh_token, :string
    remove_column :site_infos, :error_details
  end
end
