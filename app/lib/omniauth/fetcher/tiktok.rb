class OmniAuth::Fetcher::Tiktok
  ACCESS_TOKEN_URL = 'https://open.tiktokapis.com/v2/oauth/token/'.freeze
  USER_INFO_URL = 'https://open.tiktokapis.com/v2/user/info/?fields=open_id,display_name,profile_deep_link,follower_count,likes_count,video_count,bio_description'.freeze
  VIDEO_INFO_URL = 'https://open.tiktokapis.com/v2/video/list/?fields=id,create_time,view_count'.freeze

  attr_accessor :refresh_token, :code

  def initialize(code: nil, refresh_token: nil)
    @code = code
    @refresh_token = refresh_token
  end

  def site_info_attributes
    {
      account_id: user_data['open_id'],
      account_type: SiteInfo.account_type_tiktok,
      description: "Tiktok Account (#{user_data['display_name']})",
      media_category: media_category_attributes,
      url: profile_url,
      verified: true,
      username: user_data['display_name'],
      comments: user_data['bio_description'],
    }.merge(site_info_metrics)
  end

  def site_info_metrics
    {
      followers_count: user_data['follower_count'],
      last_media_posted_at: last_media_posted_at,
      media_count: user_data['video_count'],
      unique_visit_per_month: unique_visit_per_month,
      access_token: refresh_token,
    }
  end

  def call_as_site_infos
    [site_info_attributes]
  end

  def access_token
    @access_token ||= begin
      response = RestClient.post(ACCESS_TOKEN_URL, access_token_params)
      data = JSON.parse(response.body)

      raise OmniAuth::Fetcher::Error::TokenError, "#{data['error']}: #{data['error_description']}" if data['error'].present?

      # It is valid for 365 days after the initial issuance.
      @refresh_token = data['refresh_token']

      data['access_token']
    end
  end

  private

  def access_token_params
    {
      client_key: ENV.fetch('TIKTOK_CLIENT_ID'),
      client_secret: ENV.fetch('TIKTOK_CLIENT_SECRET'),
    }.tap do |param|
      if code.present?
        param[:code] = code
        param[:grant_type] = 'authorization_code'
        param[:redirect_uri] = DotOne::ClientRoutes.affiliates_tiktok_callback_url
      else
        param[:grant_type] = 'refresh_token'
        param[:refresh_token] = refresh_token
      end
    end
  end

  def headers
    {
      Authorization: "Bearer #{access_token}",
    }
  end

  def user_data
    @user_data ||= begin
      response = RestClient.get(USER_INFO_URL, headers)
      JSON.parse(response.body).dig('data', 'user')
    end
  end

  def last_media_posted_at
    create_time = get_videos(max_count: 1).dig(0, 'create_time')
    Time.at(create_time) if create_time.present?
  end

  def get_videos(cursor: nil, max_count: 20, paginate: false)
    response = RestClient.post(VIDEO_INFO_URL, { max_count: max_count, cursor: cursor }.to_json, headers.merge(content_type: :json))
    result = JSON.parse(response.body).dig('data')

    list = result['videos']

    if paginate && result['has_more'] && list.last.present? && list.last['create_time'] > range_date.first
      list += get_videos(cursor: result['cursor'], paginate: true)
    end

    list
  end

  def profile_url
    links = DotOne::Services::LinkTracer.new(user_data['profile_deep_link']).trace
    raw_url = URI(links.last[:link])
    raw_url.query = nil
    raw_url.to_s
  end

  def unique_visit_per_month
    cursor = range_date.last * 1000
    videos = get_videos(cursor: cursor, paginate: true)

    videos.sum do |video|
      range_date.cover?(video['create_time']) ? video['view_count'] : 0
    end
  end

  def range_date
    @range_date ||= (1.month.ago.beginning_of_month.to_i..1.month.ago.end_of_month.to_i)
  end

  def media_category_attributes
    AffiliateTag::MediaCategorySerializer.new(media_category).attributes
  end

  def media_category
    @media_category ||= AffiliateTag.media_categories.find_by(name: 'TikTok')
  end
end
