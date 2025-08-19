class CreateChatbotSteps < ActiveRecord::Migration[6.1]
  def change
    create_table :chatbot_steps do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.text :keywords, null: false
      t.string :chatbot_type, null: false

      t.timestamps
    end
  end
end
