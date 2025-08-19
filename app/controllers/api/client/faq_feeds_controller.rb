class Api::Client::FaqFeedsController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    respond_with @faq_feeds.preload_translations(:title, :content).order(ordinal: :asc)
  end
end
