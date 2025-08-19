class RenameColumnsToRole < ActiveRecord::Migration[6.1]
  def change
    rename_column :chatbot_steps, :chatbot_type, :role
    rename_column :faq_feeds, :faq_type, :role
  end
end
