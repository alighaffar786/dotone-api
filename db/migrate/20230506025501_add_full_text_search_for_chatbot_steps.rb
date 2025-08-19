class AddFullTextSearchForChatbotSteps < ActiveRecord::Migration[6.1]
  def up
    execute(
      <<-SQL
        ALTER TABLE chatbot_steps ADD FULLTEXT(title, content, keywords);
      SQL
    )
  end

  def down
    execute(
      <<-SQL
        ALTER TABLE chatbot_steps DROP INDEX title, content, keywords;
      SQL
    )
  end
end
