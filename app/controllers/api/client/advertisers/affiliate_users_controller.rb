class Api::Client::Advertisers::AffiliateUsersController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    respond_with @affiliate_users
  end
end
