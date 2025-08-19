class ChatbotStep < DatabaseRecords::PrimaryRecord
  include AppRoleable
  include DynamicTranslatable

  validates :title, :content, :keywords, :role, presence: true

  set_dynamic_translatable_attributes(title: :plain, content: :html, keywords: :plain)

  scope :full_text_search, -> (query) {
    sql = <<-SQL.squish
      MATCH(chatbot_steps.title, chatbot_steps.content, chatbot_steps.keywords) AGAINST (:term) OR
      MATCH(translations.content) AGAINST (:term) OR
      CONCAT(chatbot_steps.title, chatbot_steps.content, chatbot_steps.keywords) LIKE :like_term OR
      translations.content LIKE :like_term
    SQL

    sanitized = sanitize_sql_like(query)

    left_joins(:translations)
      .where(sql, term: sanitized, like_term: "%#{sanitized}%")
      .group('chatbot_steps.id')
  }
end
