class Api::Client::ChatbotStepsController < Api::Client::BaseController
  load_and_authorize_resource

  after_action :log_search

  def index
    @chatbot_steps = query_index
    respond_with @chatbot_steps
  end

  private

  def query_index
    @chatbot_steps
      .full_text_search(params[:query])
      .preload_translations(:title, :content, :keywords)
      .limit(5)
  end

  def log_search
    current_user.log_chatbot_search(params[:query], current_locale)
  end
end
