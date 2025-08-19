class Api::Client::Teams::UploadsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :create
  load_and_authorize_resource through: :current_user, only: :create

  def index
    @uploads = paginate(query_index)
    respond_with_pagination @uploads
  end

  def create
    if @upload.save
      respond_with @upload
    else
      respond_with @upload, status: :unprocessable_entity
    end
  end

  def destroy
    if @upload.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private
  def query_index
    UploadCollection.new(@uploads, params).collect
  end

  def upload_params
    params.require(:upload).permit(:descriptions, :cdn_url)
  end
end
