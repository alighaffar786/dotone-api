module Track::CurrentHandler
  include CurrentHandler

  protected

  def current_mkt_site
    @current_mkt_site ||= begin
      if params[:mkt_site_id].to_i == 2488
        params[:mkt_site_id] = 2502
      end

      if params[:mkt_site_id].to_i == 2190
        params[:mkt_site_id] = 2749
      end

      mkt_site = MktSite.cached_find(params[:mkt_site_id])

      if mkt_site.blank? && domain = DotOne::Utils::Url.domain_name(request.referer)
        mkt_site = MktSite.cached_find_by_accepted_domains(domain)
      end

      Sentry.capture_exception(Exception.new(params[:mkt_site_id])) unless mkt_site

      mkt_site
    end
  end

  def current_vtm_channel
    @current_vtm_channel ||= params[:vtm_channel].presence
  end

  def current_vtm_campaign
    @current_vtm_campaign ||= params[:vtm_campaign].presence
  end

  def current_vtm_page
    @current_vtm_page ||= params[:vtm_page].presence
  end

  def current_vtm_host
    @current_vtm_host ||= params[:vtm_host].presence
  end

  def test_run?
    AffiliateStat.test_run?(params[:subid_1])
  end

  def current_device_info
    @current_device_info ||= DotOne::Track::DeviceInfo.new(user_agent: request.user_agent.to_s, full_path: request.fullpath, ip: request.ip)
  end

  def current_client_info_hash
    return @client_info_hash if @client_info_hash.present?

    # Info from request headers
    @client_info_hash = {
      http_user_agent: request.env['HTTP_USER_AGENT'],
      ip_address: request.remote_ip,
      http_referer: params[:ref] || request.referer,
    }

    @client_info_hash[:is_bot] = !!AffiliateStat.is_bot?(
      @client_info_hash[:http_user_agent],
      @client_info_hash[:ip_address],
      @client_info_hash[:http_referer],
    )

    # Info about ISP
    isp_info = begin
      ISP_DB.lookup(request.remote_ip)
    rescue IPAddr::InvalidAddressError
      {}
    end

    @client_info_hash[:isp] = isp_info.to_hash['isp']

    # Obtain device info from user agent
    device_info_data = current_device_info.to_data_for_tracking

    # Record reference about current device info for further use
    @client_info_hash[:device_info] = current_device_info

    # Info about browser
    if device_info_data.present?
      @client_info_hash.merge!(device_info_data.slice(:browser, :browser_version, :device_type, :device_brand))
      @client_info_hash[:device_model] = device_info_data[:device_model].presence&.to_yaml
    end

    @client_info_hash.with_indifferent_access
  end

  def current_subids
    params.permit(:subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :gaid).to_h.symbolize_keys
  end

  def current_vtm_data
    params.permit(:vtm_channel, :vtm_campaign, :vtm_host, :vtm_page).to_h.symbolize_keys
  end

  # tracking data is client info + query string + rails environment
  def current_tracking_data
    @current_tracking_data ||= params.permit!.to_h.merge(current_client_info_hash).with_indifferent_access
  end

  # tracking token is the indentification to determine the current tracking
  def current_tracking_token
    @current_tracking_token if @current_tracking_token.present?
    @current_tracking_token = DotOne::Track::Token.new(current_tracking_data[:token]) if current_tracking_data[:token]
    @current_tracking_token
  end

  # identify the current tracking type, since we track a bunch of stuff
  # this is based on the action name
  def set_tracking_type_as(type)
    @tracking_type = type
  end

  ##### OFFER VARIANT #####

  # helper to determine the most optimized offer variant based on current traffic configuration
  def optimize_offer_variant(offer_variant)
    return if offer_variant.blank?

    if device_type = current_tracking_data[:device_type].presence
      offer_variant.cached_offer.best_variant_for_current_device_type(device_type, offer_variant)
    elsif offer_variant.active?
      offer_variant
    end
  end

  # offer variant to track
  # only active
  def current_offer_variant
    return @current_offer_variant if @current_offer_variant.present?

    @current_offer_variant = optimize_offer_variant(OfferVariant.cached_find(current_tracking_token.offer_variant_id))
    @current_offer_variant = nil unless @current_offer_variant&.cached_offer&.cached_network&.active?
    @current_offer_variant
  end

  # only active
  def current_offer
    @current_offer ||= current_offer_variant&.cached_offer || NetworkOffer.cached_find(params[:offer_id])
  end

  # only active
  def current_default_offer_variant
    return @current_default_offer_variant if @current_default_offer_variant.present?

    @current_default_offer_variant = current_offer&.cached_default_offer_variant
    @current_default_offer_variant = nil unless @current_default_offer_variant&.active?
    @current_default_offer_variant
  end

  # affiliate to track
  # only active
  def current_affiliate
    return @current_affiliate if @current_affiliate.present?

    @current_affiliate = Affiliate.cached_find(current_tracking_token&.affiliate_id || params[:affiliate_id])
    @current_affiliate = nil unless @current_affiliate&.active?
    @current_affiliate
  end

  def current_affiliate_offer
    return @current_affiliate_offer if @current_affiliate_offer.present?

    @current_affiliate_offer = AffiliateOffer.cached_find(current_tracking_token&.affiliate_offer_id)
    @current_affiliate_offer = AffiliateOffer.active_best_match(current_affiliate, current_offer) unless @current_affiliate_offer&.active?

    if @current_affiliate_offer.blank? && current_tracking_data[:ad_slot_id].present?
      ad_slot_valid = current_tracking_data[:ad_slot_id] == 'fallback-ad-slot' || AdSlot.cached_find(current_tracking_data[:ad_slot_id])

      if ad_slot_valid
        @current_affiliate_offer ||= AffiliateOffer.best_match_or_create(current_affiliate, current_offer, true, true)
        @current_affiliate_offer = nil unless @current_affiliate_offer&.active?
      end
    end

    @current_affiliate_offer
  end

  # only active
  def current_network
    return @current_network if @current_network.present?

    @current_network = current_offer&.cached_network
    @current_network = nil unless @current_network&.active?
    @current_network
  end

  def current_channel
    @current_channel ||= Channel.cached_find(current_tracking_token.channel_id)
  end

  def current_campaign
    @current_campaign ||= Campaign.cached_find(current_tracking_token&.campaign_id || params[:campaign_id])
  end

  # to check whether the incoming tracking is unique or not
  # as indicated by the existence of the cookies.
  def tracking_unique?
    return true if test_run?
    return true if current_tracking_data[:is_bot]

    if current_tracking_data[:token].present? && cookies[current_unique_cookie_key] == current_tracking_data[:token]
      return false
    end

    true
  end

    # helper to check if the affiliate is available to run
  def affiliate_available?
    test_run? || current_affiliate.present?
  end

  def offer_available?
    current_offer_variant && current_default_offer_variant && !current_offer.cap_depleted?
  end

  def affiliate_offer_available?
    current_affiliate_offer.present? && !(current_affiliate_offer.hard? && current_affiliate_offer.cap_depleted?)
  end

  def is_source_traffic_active?
    affiliate_offer_available? || current_channel.present?
  end

  ## ========================================================== ##
  ## COOKIE FOR CLICK UNIQUENESS                                ##
  ## ========================================================== ##

  # cookie key to record tracking uniqueness on client browser
  def current_unique_cookie_key
    return @unique_cookie_key if @unique_cookie_key.present?

    @unique_cookie_key = [
      Track::CookieHandler::COOKIE_NAME_PREFIX[@tracking_type],
      current_tracking_data&.dig(:id),
      'uniq',
    ].compact.join('_')

    @unique_cookie_key
  end

  # set cookie to detect click duplicates
  def set_unique_cookie
    return if current_tracking_data[:is_bot]
    return if cookies[current_unique_cookie_key]

    cookies[current_unique_cookie_key] = { value: current_tracking_data[:token], expires: 5.minutes.from_now.utc }
  end
end
