class CreateSiteInfoCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :site_info_categories do |t|
      t.integer :category_id, index: true
      t.integer :site_info_id, index: true
    end
  end
end
