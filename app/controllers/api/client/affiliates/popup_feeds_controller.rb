class Api::Client::Affiliates::PopupFeedsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    @popup_feeds = paginate(@popup_feeds.preload_translations(:title, :button_label))
    respond_with @popup_feeds
  end
end
