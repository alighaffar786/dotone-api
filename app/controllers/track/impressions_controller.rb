class Track::ImpressionsController < Track::BaseController
  include Track::ConversionHandler
  include Track::RedirectionHandler

  skip_after_action :verify_same_origin_request
  after_action :do_save_postback, only: :mkt_site

  def ad_slot
    content = begin
      File.read("tmp/image#{params[:width]}x#{params[:height]}.html")
    rescue Errno::ENOENT
    end

    render plain: content
  end

  ##
  # Action that serves conventional banner delivery.
  # For native shopping ads, refer to Ads Controller
  def image_creative
    data_load = ImageCreative.cached_delivery(params[:id])

    if data_load.present?
      data_load.add_affiliate_offer(current_affiliate_offer)

      unless params[:inspect]
        redirect_to(data_load.to_s)
      end
    end
  end

  ##
  # Action that handles marketing site such as landing page
  # and any sub page that is included as part of offer or
  # campaign that leads to conversions.
  # This page(s) can be an entire site.
  #
  # This action will manage all the cookies necessary to
  # record and post conversions (orders) to the network.
  def mkt_site
    @response = {}

    # Determine domain used for cookie availability.
    # This tells the client's browser which subdomains
    # the cookie will be available for access.
    cookie = {
      **current_subids,
      **current_vtm_data,
      domain: current_mkt_site&.domain || current_vtm_host,
      stat_id: params[:server_subid],
    }

    @response = {
      cookie: cookie,
      cookie_bust: [], # List of cookies to reset.
      token: params[:token],
      invalid_campaign: false, # If campaign as obtained from token is not available, this flag will let the client know and act accordingly
      refresh_page: false,
      refresh_url: [params[:protocol], '//', current_vtm_host, ":#{request.port}", current_vtm_page, params[:qs]].join,
    }

    for_affiliate = current_mkt_site&.cached_affiliate.present?
    for_network = current_mkt_site&.cached_network.present?

    # for affiliate
    if for_affiliate && current_vtm_channel.present?
      tracking_token = DotOne::Track::Token.new(mkt_site_id: current_mkt_site.id, affiliate_id: current_mkt_site.affiliate_id)
      tracking_data = current_tracking_data.merge(
        **current_vtm_data,
        **current_subids,
        mkt_site: current_mkt_site.id,
      )
      AffiliateStat.record_hits(tracking_token, tracking_data)

      # record vtm channel
      VtmChannel.where(name: current_vtm_channel, affiliate_id: current_mkt_site.affiliate_id).first_or_create

      # record vtm campaign
      if current_vtm_campaign.present?
        VtmCampaign.where(name: current_vtm_campaign, affiliate_id: current_mkt.affiliate_id).first_or_create
      end
    end

    if for_network
      pixels = []

      make_sure_unique_click do
        @response = register_for_click(@response) if params[:token].present?
      end

      # convert when specified
      if conversions?
        # Prevent multiple conversion process when
        # the same conversion data is sent over
        params_to_cache = params.permit!.to_h.symbolize_keys.except(:callback, :fp)
        key = DotOne::Utils::Encryptor.hexdigest(params_to_cache.to_s)

        if current_tracking_data[:is_bot]
          Sentry.capture_exception(Exception.new(current_tracking_data))
        end

        convert_this(
          @response[:cookie][:stat_id],
          pixel_installed: 'Javascript',
          real_time: true,
          no_modification_on_final_status: true,
          delayed: true,
          captured_at: Time.now.utc.to_s(:db)
        )

        # DotOne::Cache.fetch("conversion-process-#{key}", expires_in: 5.seconds) do
        #   convert_this(
        #     @response[:cookie][:stat_id],
        #     pixel_installed: 'Javascript',
        #     real_time: true,
        #     no_modification_on_final_status: true,
        #     delayed: true,
        #     captured_at: Time.now.utc.to_s(:db)
        #   )
        # end
      end

      # obtain client pixels
      pixels << current_mkt_site.pixels(conversions: params[:conversions], vtm_channel: current_vtm_channel, step: params[:step])
      pixels = pixels.flatten
      @response[:pixel] = pixels.join('') if pixels.present?
    end

    render json: @response, callback: params[:callback]
  end

  def iframe
    size = '300x250'

    Sentry.capture_exception(Exception.new('iframe request'))

    if @affiliate = Affiliate.first
      @aff_offers = @affiliate.affiliate_offers.active
      @image_creatives = []

      if @aff_offers.present?
        @image_creatives = @aff_offers.flat_map do |offer|
           offer.offer_variant.image_creatives.where(size: '300x250', internal: false).to_a
        end
      end

      @image_creative = @image_creatives.sample
    end

    render layout: false
  end

  private

  def conversions?
    truthy?(params[:conversions]) || params.key?(:conversions) || params[:order].present?
  end

  def do_save_postback
    return unless conversions?

    save_postback(@response, @response[:cookie][:stat_id])
  end

  def register_for_click(data)
    return data if data[:token].blank?

    determine_click_logic(
      proc do
        click_stat = AffiliateStat.record_clicks(
          current_offer_variant,
          current_tracking_token,
          current_tracking_data,
          delayed: true
        )

        refresh_url = DotOne::Track::Deeplink.add_parameters(data[:refresh_url], click_stat.offer_variant, click_stat)
        token_formatter = DotOne::Track::TokenFormatter.new(refresh_url, click_stat)
        refresh_url = token_formatter.add_all(params)

        data[:cookie][:stat_id] = click_stat.to_s
        data[:refresh_page] = true
        data[:refresh_url] = refresh_url
      end,
      proc { data = invalidate_campaign(data) },
      proc { data = invalidate_campaign(data) }
    )

    data
  end

  def invalidate_campaign(data)
    data.merge(invalid_campaign: true)
  end

  ##
  # Detect for incoming traffic coming from
  # same device within 5 seconds. This is
  # to prevent our script from being printed out
  # multiple times in one page and register
  # multiple clicks on one page view
  def make_sure_unique_click
    return if current_tracking_data[:is_bot]
    return unless fingerprint = params[:fp].presence

    fp_cache_key = "fingerprint-#{fingerprint}"

    unless from_cache = DotOne::Cache.fetch(fp_cache_key).presence
      yield
      Rails.cache.write(fp_cache_key, true, expires_in: 24.hours)
    end
  end
end
