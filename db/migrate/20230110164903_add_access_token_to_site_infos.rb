class AddAccessTokenToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :access_token, :text
  end
end
