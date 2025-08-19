class AddMessengerToContactLists < ActiveRecord::Migration[6.1]
  def change
    add_column :contact_lists, :messenger_service, :string
    add_column :contact_lists, :messenger_id, :string
  end
end
