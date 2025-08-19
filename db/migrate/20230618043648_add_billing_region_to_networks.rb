class AddBillingRegionToNetworks < ActiveRecord::Migration[6.1]
  def change
    change_column_default :attachments, :legacy, true
    add_column :networks, :billing_region, :string
  end
end
