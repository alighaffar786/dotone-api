class Api::Client::Advertisers::DownloadsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @downloads = paginate(@downloads.order(created_at: :desc))
    respond_with_pagination @downloads
  end

  def destroy
    if @download.destroy
      render json: { message: 'Destroyed successfully' }
    else
      respond_with @download, status: :unprocessable_entity
    end
  end
end
