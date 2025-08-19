class Api::V2::Advertisers::NetworkOffersController < Api::V2::Advertisers::BaseController
  load_and_authorize_resource

  def show
    respond_with @network_offer
  end
end
