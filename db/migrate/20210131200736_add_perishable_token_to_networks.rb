class AddPerishableTokenToNetworks < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:networks, :persistence_token)
      add_column :networks, :persistence_token, :string, :default => "", :null => false
    end

    unless index_exists?(:networks, :persistence_token)
      add_index :networks, :persistence_token
    end
  end
end
