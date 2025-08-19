require 'net/https'

class Track::ClicksController < Track::BaseController
  include Track::RedirectionHandler

  before_action :check_if_blocked, only: :offer_variant
  after_action :record_domain_clicks, only: :offer_variant

  def geo_filter
    @current_offer = NetworkOffer.cached_find(params[:offer_id])
    check_on_click_geo_filter({ user_agent: request.env['HTTP_USER_AGENT'], offer_id: current_offer.id })

    redirect_to_terminal('Offer available', false)
  rescue DotOne::Errors::ClickError::InvalidGeoError
    render :geo_filter
  end

  ##
  # Method to redirect from cloacking using form post redirect.
  # params[:t] contains the Target URL
  def form_redirect
    if params[:t].present?
      redirect_to params[:t], status: 301
    else
      redirect_to_terminal('No t param given')
    end
  end

  ##
  # Method to handle the offer/campaign clicks
  # from affiliate's Tracking URL
  def offer_variant
    set_tracking_type_as(:offer_variant)

    if test_run?
      run_offer_click && return
    elsif current_affiliate.blank?
      redirect_to_terminal('No Active Affiliate', false)
    elsif current_affiliate_offer.blank?
      redirect_to_terminal('No Active Campaign', false)
    else
      determine_click_logic(
        proc { run_offer_click },
        proc { go_to_alternate_destination },
        proc { redirect_to_terminal('Click logic last stage') }
      )
    end
  end

  ##
  # Handle affiliate referral campaign click.
  # It will points to the offer tagged as affiliate
  # referral target
  def affiliate_referral
    @current_affiliate = DotOne::Setup.missing_credit_affiliate unless current_affiliate
    @current_offer_variant = OfferVariant.for_referral
    @referral_campaign = AffiliateOffer.best_match_or_create(current_affiliate, current_offer, true)

    if @current_affiliate.blank? || @current_offer_variant.blank? || @referral_campaign.blank?
      Sentry.capture_exception(Exception.new("Missing args: #{@current_affiliate&.id} - #{@current_offer_variant&.id} - #{@referral_campaign&.id}"), extra: {
        campaign_id: AffiliateOffer.find_by(affiliate_id: @current_affiliate&.id, offer_id: current_offer&.id)&.id,
      })
    end

    @current_tracking_token = DotOne::Track::Token.new(
      affiliate_id: @current_affiliate.id,
      affiliate_offer_id: @referral_campaign.id,
      offer_variant_id: @current_offer_variant.id
    )

    run_offer_click
  end

  def campaign
    # if current_campaign.present?
    token = DotOne::Track::Token.new(
      campaign_id: current_campaign.id,
      channel_id: current_campaign.channel_id
    )

    uri = DotOne::Utils::Url.parse(current_campaign.destination_url)

    query = uri.query_values || {}

    # Carry over subid data to the Target URL
    query = query.merge(current_subids)

    query['channel_id'] = '-transaction_channel_id-'
    query['campaign_id'] = '-transaction_campaign_id-'
    query['vtm_token'] = token.encrypted_string
    query['vtm_stat_id'] = '-transaction_id-'
    query['vtmz'] = 'true'

    uri.query_values = query

    redirect_to uri.to_s
    # else
    #   raise ActiveRecord::RecordNotFound
    # end
  end

  private

  def check_if_blocked
    to_check = [
      request.user_agent,
      request.remote_ip,
      DotOne::Utils::Url.host_name(request.referer),
      DotOne::Utils::Url.host_name(params[:t]),
      params[:t],
      params[:token],
    ].compact_blank

    if ClickAbuseReport.check_blocked?(*to_check)
      head :bad_request
    end
  end

  ##
  # Helper to run click on the supplied offer variant
  def run_offer_click(options = {})
    unless current_offer_variant
      redirect_to_terminal('Offer Not available', false) && return
    end

    inspect_info = {
      original_offer_variant_id: current_offer_variant.id,
      affiliate_available: affiliate_available?,
      affiliate_offer_available: affiliate_offer_available?,
      network_available: current_network.present?,
      offer_available: offer_available?,
      user_agent: request.env['HTTP_USER_AGENT']
    }

    check_on_click_run(inspect_info)

    # Check for optimized device filter
    if current_tracking_data[:device_info].present?
      device_filters_result = current_tracking_data[:device_info].violate_device_filters?(current_offer_variant, [], nil, current_affiliate)
      inspect_info[:device_filter_info] = current_tracking_data[:device_info].formatted_device_info
    end

    unless params[:inspect]
      if device_filters_result == true
        redirect_to_terminal('Device not compatible with this offer.', false) && return
      elsif device_filters_result.present?
        @current_offer_variant = device_filters_result
      end
    end

    set_entity_cookie = false

    if tracking_unique?
      # This is unique click, thus set cookie and track it
      set_unique_cookie
      set_entity_cookie = true

      click_stat = AffiliateStat.record_clicks(
        current_offer_variant,
        current_tracking_token,
        current_tracking_data,
        options.merge(test: test_run?, delayed: true)
      )
    else
      # This is not a unique click, retrieve data from cookie and redirect
      cookie_data = get_entity_cookie(current_offer_variant)

      click_stat = ClickStat.new(
        **current_subids,
        **params.slice(:gaid, :ios_uniq, :android_uniq),
        id: cookie_data,
        offer_variant_id: current_offer_variant.id,
        affiliate_id: current_affiliate.id,
        v2: current_tracking_token.v2,
      )
    end

    redirect_routine(click_stat, current_offer_variant, device_filters_result, set_entity_cookie: set_entity_cookie, inspect_info: inspect_info)
  end

  ##
  # Private method to execute all routines for click redirection
  def redirect_routine(click_stat, offer_variant, device_filters_result, options = {})
    if click_stat.blank?
      redirect_to_terminal('Click or offer not found') && return
    end

    inspect_info = options[:inspect_info] || {}
    set_entity_cookie(click_stat) if options[:set_entity_cookie] == true

    @target_url = click_stat.url

    if current_offer.deeplinkable?
      t_url = params[:t]

      if params[:t] && params[:t_encrypted] == 'true'
        t_url = DotOne::Utils::Encryptor.decrypt(params[:t])
      end

      # Rollback any escaped characters when direct deeplinking
      # where advertiser does not have jump page. This is necessary for URL that contains
      # any chinese or other unicode characters
      if t_url.present?
        t_url = DotOne::Track::Deeplink.parse_t_params(t_url, v2: click_stat.v2?)

        if DotOne::Track::Deeplink.contain_deeplink_token?(click_stat.url)
          t_url = URI::DEFAULT_PARSER.escape(t_url)
        end
      end

      if custom_url = t_url.presence
        whitelisted, new_url = DotOne::Track::Deeplink.host_in_whitelisted?(offer_variant, custom_url, v2: click_stat.v2?)

        unless whitelisted
          AffiliateStats::RecordClickAbuseJob.perform_later(
            token: current_tracking_data[:token],
            raw_request: request.original_url,
            user_agent: request.user_agent.to_s,
            referer: request.referer,
            ip_address: request.remote_ip,
            error_details: DotOne::Utils.to_utf8(params[:t]),
          )
          redirect_to_terminal('Destination URL doesn not match', false) && return
        end

        custom_url = new_url

        if deeplink_modifier = offer_variant.cached_offer.deeplink_modifier.presence
          deeplink_modifier_original = deeplink_modifier.dig(:original)
          deeplink_modifier_replacement = deeplink_modifier.dig(:replacement)

          custom_url = custom_url.gsub(deeplink_modifier_original.to_s, deeplink_modifier_replacement.to_s)
          custom_url = custom_url.gsub('AFONESDP', 'TWAFSDP')
        end
      end
    end

    # Determine Deeplink URL to use. Only consider the offer's destination URL
    # when Deeplink token is present and custom URL is not present
    deeplink_url = if custom_url.blank? && DotOne::Track::Deeplink.contain_deeplink_token?(click_stat.url)
      current_offer.destination_url
    else
      custom_url
    end

    custom_url = DotOne::Track::Deeplink.add_parameters(deeplink_url, offer_variant, click_stat)
    @target_url = DotOne::Track::Deeplink.choose_redirection(custom_url, click_stat.url)

    if @target_url.blank?
      redirect_to_terminal('Target URL is blank on `DotOne::Track::Deeplink.choose_redirection`') && return
    end

    @target_url = interpolate_from_params(@target_url, t: (custom_url || current_offer.destination_url))

    if @target_url.blank?
      redirect_to_terminal('Target URL is blank on `interpolate_from_params`') && return
    end

    token_formatter = DotOne::Track::TokenFormatter.new(@target_url, click_stat)
    @target_url = token_formatter.add_all(params)
    @target_url = DotOne::Utils::Converter.format_expression(@target_url)

    if @target_url.blank?
      redirect_to_terminal('Target URL is blank on `DotOne::Utils::Converter.format_expression`') && return
    end

    # Some advertisers prefer to grab our transaction id
    # via header's data instead of query strings.
    # We provide the header version here
    response.headers['TID'] = click_stat.id

    if params[:inspect]
      @inspect_result = inspect_info.merge(
        target_url: @target_url,
        tid: click_stat.id,
        offer_variant_id: offer_variant.id,
        device_filter_offer_variant_id: (device_filters_result && device_filters_result.is_a?(OfferVariant) && device_filters_result.id),
        tracking_token: current_tracking_token.to_s
      )

      respond_with(@inspect_result)
    else
      redirect!(@target_url)
    end
  end

  def record_domain_clicks
    DotOne::Kinesis::Client.to_kinesis(
      DotOne::Kinesis::TASK_SAVE_TRACKING_DOMAIN_STAT,
      {},
      date: Date.today, url: DotOne::Utils.to_utf8(request.url),
    )
  end
end
