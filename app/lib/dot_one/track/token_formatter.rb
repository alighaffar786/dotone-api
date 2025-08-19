class DotOne::Track::TokenFormatter
  attr_reader :url, :click_stat, :formatted_url

  def initialize(url, click_stat)
    @url = url
    @click_stat = click_stat
    @formatted_url = url
  end

  def add_all(params = {})
    if add_affiliate_info(params).blank?
      raise 'Target URL is blank on `add_affiliate_info`'
    end

    if add_offer_info(params).blank?
      raise 'Target URL is blank on `add_offer_info`'
    end

    if add_campaign_info.blank?
      raise 'Target URL is blank on `add_campaign_info`'
    end

    if add_transaction_info.blank?
      raise 'Target URL is blank on `add_transaction_info`'
    end

    if add_vtm_info.blank?
      raise 'Target URL is blank on `add_vtm_info`'
    end

    @formatted_url
  end

  def add_affiliate_info(params = {})
    if affiliate = click_stat.affiliate
      @formatted_url = affiliate.format_content(formatted_url, :url, {}, params['kvp_tag'])
    end

    @formatted_url
  end

  def add_offer_info(params = {})
    if offer = click_stat.offer
      @formatted_url = offer.format_content(formatted_url, :url, {}, params['kvp_tag'])
    end

    @formatted_url
  end

  def add_campaign_info
    if affiliate_offer = click_stat.affiliate_offer
      @formatted_url = affiliate_offer.format_content(formatted_url, :url)
    end

    @formatted_url
  end

  def add_transaction_info
    if stat = click_stat.to_stat
      @formatted_url = stat.format_content(formatted_url, :url)
    end

    @formatted_url
  end

  def add_vtm_info(params = {})
    return formatted_url unless mkt_site = MktSite.cached_find_by_offer_id(click_stat.offer_id)
    return formatted_url unless uri = DotOne::Utils::Url.parse(formatted_url)

    query = uri.query_values
    query = {} if query.blank?
    query['vtm_channel'] = DotOne::Setup.wl_setup(:network_channel_name) if query['vtm_channel'].blank?
    query['vtm_stat_id'] = click_stat.to_s
    query['vtm_token'] = params[:token].encrypted_string if params[:token].present?

    # Extra parameter to make sure cookie name 'vtm_stat_id'
    # is not being misread from part of the request URL.
    # This could happen when the request URL is stored in a cookie.
    query['vtmz'] = 'true'

    uri.query_values = query
    @formatted_url = uri.to_s
    @formatted_url
  end
end
