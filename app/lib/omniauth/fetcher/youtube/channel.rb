require 'google/apis/youtube_analytics_v2'
require 'google/apis/youtube_v3'

class OmniAuth::Fetcher::Youtube::Channel
  attr_accessor :channel, :auth, :start_date, :end_date

  def self.all(auth)
    youtube_api(auth).list_channels([:id, :snippet, :statistics, :content_details], mine: true).items.to_a
  end

  def self.youtube_api(auth)
    Google::Apis::YoutubeV3::YouTubeService.new.tap do |service|
      service.authorization = auth
    end
  end

  def self.report_api(auth)
    Google::Apis::YoutubeAnalyticsV2::YouTubeAnalyticsService.new.tap do |service|
      service.authorization = auth
    end
  end

  def initialize(channel, auth)
    @auth = auth
    @start_date = 1.month.ago.beginning_of_month.strftime('%Y-%m-%d')
    @end_date = Date.today.strftime('%Y-%m-%d')

    @channel = if channel.respond_to?(:id)
      channel
    else
      youtube_api.list_channels([:id, :snippet, :statistics, :content_details], id: channel).items.first
    end
  end

  def site_info_attributes
    {
      account_id: channel.id,
      account_type: SiteInfo.account_type_youtube,
      description: "Youtube Channel (#{channel.snippet.title})",
      media_category: media_category_attributes,
      media_count: channel.statistics.video_count,
      url: "https://youtube.com/channel/#{channel.id}",
      verified: true,
      username: channel.snippet.custom_url.sub('@', ''),
    }.merge(site_info_metrics)
  end

  def site_info_metrics
    {
      followers_count: channel.statistics.subscriber_count,
      last_media_posted_at: last_media_posted_at,
      unique_visit_per_day: unique_visit_per_day,
      unique_visit_per_month: unique_visit_per_month,
      access_token: auth.refresh_token,
    }
  end

  private

  def youtube_api
    @youtube_api ||= self.class.youtube_api(auth)
  end

  def report_api
    @report_api ||= self.class.report_api(auth)
  end

  def last_media_posted_at
    return if channel.statistics.video_count == 0

    res = youtube_api.list_playlist_items('snippet', playlist_id: channel.content_details.related_playlists.uploads)
    DateTime.parse(res.items.first.snippet.published_at)
  end

  def unique_visit_per_day
    value = report_api
      .query_report(**report_options(channel.id, 'day'))
      .rows.map(&:last).max
    SiteInfo.to_unique_visit_per_day(value)
  end

  def unique_visit_per_month
    params = report_options(channel.id, 'month').merge(end_date: Date.today.beginning_of_month.strftime('%Y-%m-%d'))
    report_api.query_report(**params).rows.map(&:last).max
  end

  def report_options(channel_id, type)
    {
      dimensions: type,
      end_date: end_date,
      ids: "channel==#{channel_id}",
      metrics: 'views',
      sort: type,
      start_date: start_date,
    }
  end

  def media_category_attributes
    AffiliateTag::MediaCategorySerializer.new(media_category).attributes
  end

  def media_category
    @media_category ||= AffiliateTag.media_categories.find_by(name: 'Youtube')
  end
end
