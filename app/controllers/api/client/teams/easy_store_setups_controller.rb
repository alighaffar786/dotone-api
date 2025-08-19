class Api::Client::Teams::EasyStoreSetupsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with_pagination paginate(query_index)
  end

  def destroy
    if @easy_store_setup.destroy
      head 200
    else
      respond_with @easy_store_setup, status: :unprocessable_entity
    end
  end

  private

  def query_index
    EasyStoreSetupCollection.new(current_ability, params).collect.preload(:network, :offer)
  end
end
