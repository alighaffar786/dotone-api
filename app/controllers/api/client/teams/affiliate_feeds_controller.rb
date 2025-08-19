class Api::Client::Teams::AffiliateFeedsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @affiliate_feeds = paginate(query_index)
    respond_with_pagination @affiliate_feeds, meta: { t_columns: AffiliateFeed.dynamic_translatable_attribute_types }
  end

  def create
    if @affiliate_feed.save
      respond_with @affiliate_feed
    else
      respond_with @affiliate_feed, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_feed.update(affiliate_feed_params)
      respond_with @affiliate_feed
    else
      respond_with @affiliate_feed, status: :unprocessable_entity
    end
  end

  def destroy
    if @affiliate_feed.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    collection = AffiliateFeedCollection.new(current_ability, params).collect
    collection.preload(:countries).preload_translations(:title, :content)
  end

  def affiliate_feed_params
    assign_local_time_params(affiliate_feed: [:sticky_until, :published_at, :republished_at])

    params.require(:affiliate_feed).permit(
      :title, :content, :sticky, :status, :role, :feed_type,
      country_ids: [], sticky_until_local: [], published_at_local: [], republished_at_local: [],
      translations_attributes: [:id, :locale, :field, :content]
    )
  end
end
