class AddAccountIdToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :site_infos, :account_id, :string
    add_column :site_infos, :account_type, :string
    add_column :site_infos, :username, :string

    add_index :site_infos, :account_id
    add_index :site_infos, [:account_id, :account_type]

    execute(
      <<-SQL
        UPDATE site_infos
        SET account_id = instagram_id, username = instagram_username, account_type = 'instagram'
        WHERE instagram_id IS NOT NULL
      SQL
    )

    remove_column :site_infos, :instagram_id
    remove_column :site_infos, :instagram_username
  end
end
