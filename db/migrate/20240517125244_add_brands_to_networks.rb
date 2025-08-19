class AddBrandsToNetworks < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :brands, :json
  end
end
