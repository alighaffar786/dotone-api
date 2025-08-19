class Api::Client::Affiliates::PartnerAppsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    respond_with @partner_apps
  end
end
