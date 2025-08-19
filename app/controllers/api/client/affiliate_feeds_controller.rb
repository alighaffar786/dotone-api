class Api::Client::AffiliateFeedsController < Api::Client::BaseController
  def index
    authorize! :read, AffiliateFeed
    @affiliate_feeds = paginate(query_index)
    respond_with_pagination @affiliate_feeds
  end

  def recent
    authorize! :read, AffiliateFeed
    @affiliate_feeds = query_recent
    respond_with @affiliate_feeds
  end

  private

  def query_index
    AffiliateFeedCollection.new(current_ability, params)
      .collect
      .where('published_at <= ?', current_time_zone.from_utc(Time.now).end_of_day)
      .preload_translations(:title, :content)
  end

  def query_recent
    query_index
      .with_stickies(true)
      .latest_stickies
      .or(query_index.with_stickies(false))
      .limit(params[:limit] || 3)
  end
end
