class AddUuidToChatRoom < ActiveRecord::Migration[6.1]
  def change
    add_column :chat_rooms, :uuid, :string
    add_index  :chat_rooms, :uuid, unique: true
  end
end
