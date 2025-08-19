class Api::V2::Affiliates::AffiliatesController < Api::V2::Affiliates::BaseController
  def current
    authorize! :read, current_user
    respond_with current_user
  end
end
