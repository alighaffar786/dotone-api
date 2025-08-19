class Api::Client::ApiKeysController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index
  end

  def create
    if @api_key.save
      respond_with @api_key
    else
      respond_with @api_key, status: :unprocessable_entity
    end
  end

  def update
    if @api_key.update(api_key_params)
      respond_with @api_key
    else
      respond_with @api_key, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_key.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    ApiKeyCollection.new(current_ability, params).collect
  end

  def api_key_params
    return unless action_name.to_sym != :create || params[:api_key].present?

    params.require(:api_key).permit(:status)
  end
end
