class Api::Client::Teams::LinkTracersController < Api::Client::Teams::BaseController
  authorize_resource class: false

  def index
    @links = DotOne::Services::LinkTracer.new(params[:link]).trace

    if @links.empty?
      render json: { message: "No links found" }, status: 422
    else
      respond_with @links
    end
  end
end
