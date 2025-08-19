class Api::Client::SearchKeysController < Api::Client::BaseController
  def create
    authorize! :create, :search_key

    search_key = store_search_params

    respond_with({ search_key: search_key })
  end

  private

  def store_search_params
    search_key = DotOne::Utils.to_cache_key([], search_key_params)
    Rails.cache.write(search_key, search_key_params, expires_in: CACHE_DURATION)
    search_key
  end

  def search_key_params
    params.require(:search_key).permit(:field, :partial_by, search: [])
  end

  def require_params
    params.require(:search_key).require(:field)
    params.require(:search_key).require(:search)
  end
end
