class AddColumnScreenShotCdnUrlMissingOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :missing_orders, :screenshot_cdn_url, :text
  end
end
