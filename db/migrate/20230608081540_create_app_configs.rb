class CreateAppConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :app_configs do |t|
      t.string :role
      t.text :profile_bg_url
      t.text :logo_url
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
