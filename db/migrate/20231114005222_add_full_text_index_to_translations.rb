class AddFullTextIndexToTranslations < ActiveRecord::Migration[6.1]
  def up
    execute(
      <<-SQL.squish
        ALTER TABLE translations
        ADD FULLTEXT INDEX full_text_idx (content)
      SQL
    )
  end

  def down
    execute(
      <<-SQL.squish
        ALTER TABLE translations
        DROP INDEX full_text_idx
      SQL
    )
  end
end
