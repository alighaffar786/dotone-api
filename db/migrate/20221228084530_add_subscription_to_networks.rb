class AddSubscriptionToNetworks < ActiveRecord::Migration[6.1]
  def up
    add_column :networks, :subscription, :string, default: Network.subscription_regular

    Network.update_all(subscription: Network.subscription_regular)
  end

  def down
    remove_column :networks, :subscription
  end
end
