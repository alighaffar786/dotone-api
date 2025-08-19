class Api::Client::Teams::SessionsController < Api::Client::Teams::BaseController
  include Api::Client::SessionHelper

  before_action :validate_domain, only: :create_by_token

  def create
    authorize! :login, AffiliateUser
    @affiliate_user = AffiliateUser.authenticate(auth_params)

    respond_with_auth_token(@affiliate_user)
  end

  def create_by_token
    authorize! :login, AffiliateUser

    @affiliate_user = AffiliateUser.find_by(unique_token: auto_auth_token['unique_token'])
    respond_with_auth_token(@affiliate_user) do
      @affiliate_user.refresh_unique_token
    end
  end
end
