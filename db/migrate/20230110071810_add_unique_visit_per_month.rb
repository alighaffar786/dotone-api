class AddUniqueVisitPerMonth < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :unique_visit_per_month, :integer, default: 0
  end
end
