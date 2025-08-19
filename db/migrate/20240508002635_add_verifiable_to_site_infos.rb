class AddVerifiableToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :verifiable, :boolean, default: true
  end
end
