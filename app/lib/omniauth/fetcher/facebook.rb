class OmniAuth::Fetcher::Facebook
  attr_accessor :affiliate, :auth, :graph, :long_live_token

  def self.call(auth, affiliate = nil)
    new(auth, affiliate).call
  end

  def initialize(auth, affiliate = nil)
    @affiliate = affiliate
    @auth = auth
    @long_live_token = Koala::Facebook::OAuth.new.exchange_access_token_info(auth.credentials.token)
    @graph = Koala::Facebook::API.new(@long_live_token['access_token'])
  end

  def call
    pages.each do |page|
      Page.call(page, affiliate)
    end
  end

  def call_as_site_infos
    pages.flat_map do |page|
      fetcher = Page.new(page)
      result = [
        fetcher.site_info_attributes.merge(media_category: fetcher.media_category_attributes)
      ]

      if instagram_page = page['connected_instagram_account'].presence
        instagram_page.merge!('access_token' => page['access_token'])
        instagram_fetcher = OmniAuth::Fetcher::Facebook::Page::Instagram.new(instagram_page)
        result << instagram_fetcher.site_info_attributes.merge(media_category: instagram_fetcher.media_category_attributes)
      end

      result
    end
  end

  def pages
    @pages ||= graph.get_object('me/accounts?fields=connected_instagram_account,access_token').to_a
  end
end
