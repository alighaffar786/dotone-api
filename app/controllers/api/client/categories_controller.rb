class Api::Client::CategoriesController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    data = fetch_global_cached_on_controller { @categories.to_a }
    respond_with data, each_serializer: CategorySerializer
  end
end
