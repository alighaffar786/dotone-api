class OmniAuth::Fetcher::Facebook::Page
  attr_accessor :page, :account_id, :graph, :affiliate

  def self.call(page, affiliate = nil)
    new(page, affiliate).call
  end

  def initialize(page, affiliate = nil)
    @page = page
    @account_id = page['id']
    @graph = Koala::Facebook::API.new(page['access_token'])
    @affiliate = affiliate
  end

  def call
    return unless affiliate

    affiliate.site_infos.where(
      account_id: account_id,
      account_type: SiteInfo.account_type_facebook,
    ).first_or_initialize.tap do |site_info|
      site_info.assign_attributes(site_info_attributes)
      site_info.media_category = media_category
    end

    return unless instagram_page = page['connected_instagram_account'].presence

    instagram_page.merge!('access_token' => page['access_token'])
    Instagram.new(instagram_page, affiliate).call
  end

  class Instagram < OmniAuth::Fetcher::Facebook::Page
    def call
      return unless affiliate

      affiliate.site_infos.where(
        account_id: account_id,
        account_type: SiteInfo.account_type_instagram,
      ).first_or_initialize.tap do |site_info|
        site_info.assign_attributes(site_info_attributes)
        site_info.media_category = media_category
      end
    end

    def site_info_attributes
      super.merge(
        account_type: SiteInfo.account_type_instagram,
        description: "Instagram Account (#{details['name'].presence || details['username']})",
        url: "https://instagram.com/#{details['username']}",
        username: details['username'],
      ).merge(site_info_metrics)
    end

    def site_info_metrics
      super.merge(
        # last_media_posted_at: media ? media['timestamp'] : nil,
        media_count: details['media_count'],
      )
    end

    private

    def media_category
      @media_category ||= AffiliateTag.media_categories.find_by(name: 'Instagram')
    end

    # IG User details documentation
    # https://developers.facebook.com/docs/instagram-api/reference/ig-user
    def details
      @details ||= graph.get_object("#{account_id}?fields=id,username,followers_count,name")
    end

    # IG User Media documentation
    # https://developers.facebook.com/docs/instagram-api/reference/ig-user/media
    def media
      @media ||= graph.get_object("#{account_id}/media?fields=timestamp&limit=1").first
    end

    # IG User Insights documentation
    # https://developers.facebook.com/docs/instagram-api/reference/ig-user/insights
    def insights_per_day
      @insights_per_day ||= graph.get_object("#{account_id}/insights?metric=impressions&period=day")
    end

    def insights_per_month
      @insights_per_month ||= graph.get_object("#{account_id}/insights?metric=impressions&period=days_28")
    end
  end

  def site_info_attributes
    {
      account_id: account_id,
      account_type: SiteInfo.account_type_facebook,
      description: "Facebook Page (#{details['name']})",
      url: details['link'],
      verified: true,
    }.merge(site_info_metrics)
  end

  def site_info_metrics
    {
      access_token: Koala::Facebook::OAuth.new.exchange_access_token(page['access_token']),
      followers_count: details['followers_count'],
      # last_media_posted_at: media ? media['created_time'] : nil,
      # unique_visit_per_day: unique_visit_per_day,
      # unique_visit_per_month: unique_visit_per_month,
    }
  rescue Koala::Facebook::OAuthTokenRequestError => e
    raise OmniAuth::Fetcher::Error::TokenError, e.message
  end

  def media_category_attributes
    AffiliateTag::MediaCategorySerializer.new(media_category).attributes
  end

  protected

  def media_category
    @media_category ||= AffiliateTag.media_categories.find_by(name: 'Facebook')
  end

  def unique_visit_per_day
    value = insights_per_day.first['values'].map { |v| v['value'] }.max
    SiteInfo.to_unique_visit_per_day(value)
  end

  def unique_visit_per_month
    insights_per_month.first['values'].map { |v| v['value'] }.max
  end

  # Page details documentation
  # https://developers.facebook.com/docs/graph-api/reference/v15.0/page/
  def details
    @details ||= graph.get_object("#{account_id}?fields=id,name,link,followers_count")
  end

  # Page Feed documentation
  # https://developers.facebook.com/docs/graph-api/reference/v15.0/page/feed/
  def media
    @media ||= graph.get_object("#{account_id}/feed?fields=created_time&limit=1").first
  end

  # Page Insights documentation
  # https://developers.facebook.com/docs/graph-api/reference/v15.0/page/insights/
  def insights_per_day
    @insights_per_day ||= graph.get_object("#{account_id}/insights?metric=page_impressions&period=day")
  end

  def insights_per_month
    @insights_per_month ||= graph.get_object("#{account_id}/insights?metric=page_impressions&period=days_28")
  end
end
