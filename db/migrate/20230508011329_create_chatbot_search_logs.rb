class CreateChatbotSearchLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :chatbot_search_logs do |t|
      t.references :owner, polymorphic: true, null: false
      t.text :keyword, null: false
      t.references :language

      t.timestamps
    end

    add_reference :chatbot_steps, :language
  end
end
