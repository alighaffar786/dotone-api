class Api::Client::Teams::PopupFeedsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @popup_feeds = paginate(query_popup_feeds)
    respond_with_pagination @popup_feeds, meta: { t_columns: PopupFeed.dynamic_translatable_attribute_types }
  end

  def create
    if @popup_feed.save
      respond_with @popup_feed
    else
      respond_with @popup_feed, status: :unprocessable_entity
    end
  end

  def update
    if @popup_feed.update(popup_feed_params)
      respond_with @popup_feed
    else
      respond_with @popup_feed, status: :unprocessable_entity
    end
  end

  def destroy
    if @popup_feed.destroy
      head 200
    else
      respond_with @popup_feed, status: :unprocessable_entity
    end
  end

  private

  def query_popup_feeds
    @popup_feeds = @popup_feeds.preload_translations(:title, :button_label).order(start_date: :desc)
    @popup_feeds = @popup_feeds.active if params[:active].present?
    @popup_feeds
  end

  def popup_feed_params
    params
      .require(:popup_feed)
      .permit(
        :title, :button_label, :published, :cdn_url, :url, :start_date, :end_date,
        translations_attributes: [:id, :locale, :field, :content]
      )
  end
end
