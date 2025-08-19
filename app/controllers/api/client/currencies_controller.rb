class Api::Client::CurrenciesController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    data = fetch_global_cached_on_controller { @currencies.to_a }
    respond_with data, each_serializer: CurrencySerializer
  end
end
