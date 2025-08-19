class CreateAffiliateProspects < ActiveRecord::Migration[6.1]
  def change
    create_table :publisher_prospects do |t|
      t.string :email
      t.integer :country_id, null: true, foreign_key: true, index: true
      t.integer :affiliate_id, null: true, foreign_key: true, index: true
      t.integer :recruiter_id, null: true, foreign_key: true, index: true

      t.timestamps
    end

    add_index :publisher_prospects, :email, unique: true

    add_column :site_infos, :affiliate_prospect_id, :integer, null: true, foreign_key: true, index: true
    add_column :site_infos, :appearance, :string, null: true

    create_table :affiliate_prospect_categories do |t|
      t.integer :affiliate_prospect_id, foreign_key: true, index: true
      t.integer :category_id, foreign_key: true, index: true

      t.timestamps
    end

    add_index :affiliate_prospect_categories, [:affiliate_prospect_id, :category_id], unique: true, name: 'idx_affiliate_prospect_id_category_id'
  end
end
