class Api::V2::Affiliates::ProductsController < Api::V2::Affiliates::BaseController
  load_and_authorize_resource

  before_action :set
  before_action :validate

  def index
    @products = paginate(query_index)
    respond_with_pagination @products, campaign: @campaign
  end

  private

  def query_index
    ProductCollection.new(current_ability, params).collect
  end

  def set
    @offer = NetworkOffer.accessible_by(current_ability).find_by(id: params[:offer_id])
    @campaign = AffiliateOffer.active_best_match(current_user, @offer) if @offer.present?
  end

  def validate
    raise DotOne::Errors::ApiRequestError.new(nil, 'api_request.missing_campaign') if @campaign.blank?
  end

  def require_params
    params.require(:offer_id)
  end
end
