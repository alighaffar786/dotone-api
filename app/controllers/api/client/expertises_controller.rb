class Api::Client::ExpertisesController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    respond_with @expertises
  end
end
