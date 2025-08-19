class Api::Client::Affiliates::ImageCreativesController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource only: :index
  load_resource except: :index

  def index
    @image_creatives = paginate(query_index)
    respond_with_pagination @image_creatives
  end

  def record_download
    authorize! :read, @image_creative
    @image_creative.record_ui_download!
    head :ok
  end

  private

  def query_index
    ImageCreativeCollection.new(@image_creatives.publishable, params)
      .collect
      .preload(:offer)
  end
end
