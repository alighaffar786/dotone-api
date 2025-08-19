class Api::Client::Teams::ClientApisController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @client_apis = paginate(query_index)
    respond_with_pagination @client_apis
  end

  def create
    if @client_api.save
      respond_with @client_api
    else
      respond_with @client_api, status: :unprocessable_entity
    end
  end

  def update
    if @client_api.update(client_api_params)
      respond_with @client_api
    else
      respond_with @client_api, status: :unprocessable_entity
    end
  end

  def import
    @client_api.queue_import
    head :ok
  end

  def destroy
    if @client_api.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    ClientApiCollection.new(@client_apis, params).collect.preload(:owner)
  end

  def client_api_params
    params.require(:client_api).permit(
      :owner_id, :owner_type, :api_type, :key, :host, :api_affiliate_id, :name, :status, :path,
      :request_body_content, :username, :password, :auth_token
    )
  end
end
