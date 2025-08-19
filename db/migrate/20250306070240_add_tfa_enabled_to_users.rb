class AddTfaEnabledToUsers < ActiveRecord::Migration[6.1]
  def change
    [:affiliates, :affiliate_users, :networks].each do |table_name|
      add_column table_name, :tfa_enabled, :boolean, default: false
      add_column table_name, :tfa_code, :string, limit: 6
    end
  end
end
