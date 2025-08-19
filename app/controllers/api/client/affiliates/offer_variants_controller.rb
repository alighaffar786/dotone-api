class Api::Client::Affiliates::OfferVariantsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource :offer, only: :index
  load_and_authorize_resource through: :offer, only: :index

  def index
    respond_with @offer_variants, affiliate_offer_id: params[:affiliate_offer_id]
  end

  private

  def require_params
    params.require(:offer_id)
  end
end
