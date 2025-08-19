class RemoveLanguageIdFromChatbotSteps < ActiveRecord::Migration[6.1]
  def change
    remove_column :chatbot_steps, :language_id
  end
end
