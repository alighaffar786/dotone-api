class Api::Client::Teams::ChatbotStepsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @chatbot_steps = paginate(query_index)
    respond_with_pagination @chatbot_steps, meta: { t_columns: ChatbotStep.dynamic_translatable_attribute_types }
  end

  def create
    if @chatbot_step.save
      respond_with @chatbot_step
    else
      respond_with @chatbot_step, status: :unprocessable_entity
    end
  end

  def update
    if @chatbot_step.update(chatbot_step_params)
      respond_with @chatbot_step
    else
      respond_with @chatbot_step, status: :unprocessable_entity
    end
  end

  def destroy
    if @chatbot_step.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    @chatbot_steps
      .with_roles(params[:role])
      .preload_translations(:title, :content, :keywords)
      .order(created_at: :desc)
  end

  def chatbot_step_params
    params
      .require(:chatbot_step)
      .permit(
        :title, :content, :role, :keywords,
        translations_attributes: [:id, :locale, :field, :content]
      )
  end
end
