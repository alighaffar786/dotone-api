class AddCdnUrlsToChatMessage < ActiveRecord::Migration[6.1]
  def change
    add_column :chat_messages, :cdn_urls, :text
  end
end
