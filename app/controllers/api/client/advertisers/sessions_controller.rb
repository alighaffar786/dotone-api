class Api::Client::Advertisers::SessionsController < Api::Client::Advertisers::BaseController
  include Api::Client::SessionHelper

  before_action :validate_domain, only: :create_by_token

  def create
    authorize! :login, Network

    @network = Network.authenticate(auth_params)
    respond_with_auth_token(@network)
  end

  def create_by_token
    authorize! :login, Network

    @network = Network.find_by(unique_token: auto_auth_token['unique_token'])
    respond_with_auth_token(@network) do
      @network.refresh_unique_token
    end
  end
end
