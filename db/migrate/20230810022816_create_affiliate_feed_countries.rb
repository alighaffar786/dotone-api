class CreateAffiliateFeedCountries < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_feed_countries do |t|
      t.integer :affiliate_feed_id, null: false, foreign_key: true, index: true
      t.integer :country_id, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :affiliate_feed_countries, [:affiliate_feed_id, :country_id], unique: true, name: 'index_affiliate_feed_countries_on_feed_id_and_country_id'
  end
end
