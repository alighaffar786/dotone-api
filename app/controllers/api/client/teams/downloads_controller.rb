class Api::Client::Teams::DownloadsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @downloads = paginate(query_index)
    respond_with_pagination @downloads
  end

  def destroy
    if @download.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    DownloadCollection.new(current_ability, params).collect
  end
end
