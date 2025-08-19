class Api::V2::ProductCategoriesController < Api::V2::BaseController
  load_and_authorize_resource

  def index
    respond_with @product_categories.where(offer_id: params[:offer_id])
  end

  private

  def require_params
    params.require(:offer_id)
  end
end
