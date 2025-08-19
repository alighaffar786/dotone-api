class Api::Client::Advertisers::UploadsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource except: :create
  load_and_authorize_resource through: :current_user, only: :create

  def index
    @uploads = paginate(query_index)
    respond_with_pagination @uploads
  end

  def create
    if @upload.save
      start_stat_import_job
      respond_with @upload
    else
      respond_with @upload, status: :unprocessable_entity
    end
  end

  private

  def start_stat_import_job
    AffiliateStats::ImportJob.perform_later(@upload.id)
  end

  def query_index
    UploadCollection.new(@uploads, params).collect
  end

  def upload_params
    params.require(:upload).permit(:cdn_url, :descriptions)
  end
end
