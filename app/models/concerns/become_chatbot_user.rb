module BecomeChatbotUser
  extend ActiveSupport::Concern

  included do
    has_many :chatbot_search_logs, as: :owner, inverse_of: :owner, dependent: :destroy
  end

  def log_chatbot_search(keyword, locale = nil)
    log = chatbot_search_logs.find_or_initialize_by(keyword: keyword)
    log.locale = locale || Language.current_locale
    log.save
  end
end
