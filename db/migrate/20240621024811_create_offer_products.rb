class CreateOfferProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :offer_products, id: false, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci' do |t|
      t.string :client_id_value, limit: 50
      t.string :universal_id_value
      t.string :title
      t.text :description_1, size: :medium
      t.text :description_2, size: :medium
      t.string :brand
      t.string :category_1
      t.string :category_2
      t.string :category_3
      t.text :product_url, size: :medium
      t.boolean :is_new
      t.boolean :is_promotion
      t.datetime :promo_start_at
      t.datetime :promo_end_at
      t.string :inventory_status
      t.string :locale, limit: 5
      t.string :currency, limit: 3
      t.string :uniq_key, limit: 100
      t.integer :offer_id
      t.json :prices, size: :long
      t.json :images, size: :long
      t.json :additional_attributes, size: :long
      t.integer :client_api_id

      t.timestamps
    end

    add_index :offer_products, :client_id_value, name: :index_products_on_client_id_value
    add_index :offer_products, [:offer_id, :uniq_key], name: :index_products_on_offer_id_and_uniq_key
    add_index :offer_products, [:offer_id, :updated_at], name: :index_products_on_offer_id_updated_at
    add_index :offer_products, [:uniq_key], name: :index_products_on_uniq_key, unique: true
    add_index :offer_products, :client_api_id, name: :index_products_on_client_api_id
  end
end
