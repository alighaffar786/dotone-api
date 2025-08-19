class Api::Client::Teams::ApiKeysController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index
  end

  def active
    respond_with query_active || {}
  end

  def create
    if @api_key.save
      respond_with @api_key
    else
      respond_with @api_key, status: :unprocessable_entity
    end
  end

  def update
    if @api_key.update(api_key_params.slice(:status))
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

  def query_active
    ApiKeyCollection.new(current_ability, params.merge(owner_ids: params.delete(:owner_id))).collect.active.first
  end

  def api_key_params
    params.require(:api_key).permit(:status, :owner_id, :owner_type)
  end
end
