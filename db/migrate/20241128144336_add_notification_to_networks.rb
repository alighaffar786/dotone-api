class AddNotificationToNetworks < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :notification, :json
  end
end
