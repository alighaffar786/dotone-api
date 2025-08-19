class AddRecipientToNewsletters < ActiveRecord::Migration[6.1]
  def change
    add_column :newsletters, :sender_id, :integer
    add_column :newsletters, :role, :string
    add_column :newsletters, :recipient, :text
    add_column :newsletters, :recipient_ids, :json, array: true

    add_index :newsletters, :sender_id
  end
end
