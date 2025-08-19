class Api::Client::Advertisers::ProductsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @products = paginate(@products.es_search(params[:search])).preload(offer: :name_translations)

    respond_with_pagination @products
  end
end
