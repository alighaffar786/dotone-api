class Api::Client::Affiliates::AffiliateUsersController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    respond_with @affiliate_users
  end
end
