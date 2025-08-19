class AddMetricsLastUpdatedAtToSiteInfo < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :metrics_last_updated_at, :datetime
  end
end
