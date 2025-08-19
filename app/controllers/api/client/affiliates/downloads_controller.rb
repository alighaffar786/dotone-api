class Api::Client::Affiliates::DownloadsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    @downloads = paginate(@downloads.order(created_at: :desc))
    respond_with_pagination @downloads
  end

  def destroy
    if @download.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
