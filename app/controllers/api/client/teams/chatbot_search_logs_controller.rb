class Api::Client::Teams::ChatbotSearchLogsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @chatbot_search_logs = paginate(query_index)
    respond_with_pagination @chatbot_search_logs
  end

  private

  def query_index
    params[:days_ago] ||= 30
    ChatbotSearchLogCollection.new(@chatbot_search_logs, params).collect.preload(:owner, :language)
  end
end
