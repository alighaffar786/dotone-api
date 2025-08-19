class Track::ConversionsController < Track::BaseController
  include Track::ConversionHandler

  skip_before_action :verify_authenticity_token
  after_action :do_save_postback

  # Regular offer conversion from affiliate platform
  def global
    @response = 'FAILS'
    @stat_id = params[:server_subid].presence || get_entity_cookie(current_offer)
    @stat_id ||= custom_server_id

    if @stat_id.present?
      result = convert_this(
        @stat_id,
        pixel_installed: 'HTML',
        real_time: true,
        no_modification_on_final_status: true,
        captured_at: captured_at,
      )

      if result[:convert] == true
        @response = result[:html_pixels].join
        respond_with({ status: @response })
      else
        respond_with({ status: @response }, status: 400)
      end
    else
      respond_with({ status: @response }, status: 400)
    end
  end

  # Postback offer conversion from affiliate platform
  def offer
    @response = 'FAILS'
    process_custom_params_name(params)
    @stat_id = params[:server_subid].presence
    @stat_id ||= custom_server_id

    if is_s2s_blacklisted? || @stat_id.blank?
      respond_with({ status: @response }, status: 400)
    else
      status = 400

      result = convert_this(
        @stat_id,
        pixel_installed: 'S2S',
        real_time: true,
        no_modification_on_final_status: true,
        delayed: true,
        skip_expiration_check: true,
        captured_at: captured_at,
      )

      if result[:convert] == :delayed
        @response = 'OK'
        status = 200
      end

      if params[:inspect]
        respond_with({ status: @response }, status: status)
      else
        render json: { status: @response }, status: status
      end
    end
  end

  private

  def custom_server_id
    if request.remote_ip == '52.185.149.47'
      return '235d6c146225f1c0ef8a1604a2fbc00a'
    end

    if request.remote_ip.start_with?('103.')
      names = Offer.cached_find(2226).cached_ordered_conversion_steps.map(&:name)

      return 'adcf807c813469613e1a84cac47d3395' if names.any? { |step| step == params[:step].to_s }
    end

    if request.remote_ip == '34.150.206.12' && params[:order].to_s.start_with?('7385.')
      return '43513e70123ae2555b7ee283647b4b9e'
    end

    if request.remote_ip == '54.153.26.149' && params[:step].to_s == 'PURCHASE'
      return '1e9f4bb33991e0eb1fe7af1a97bef4e2'
    end
  rescue Exception => e
    Sentry.capture_exception(e)
  end

  def current_offer
    @current_offer ||= NetworkOffer.cached_find(params[:network_offer_id].presence || params[:id].presence)
  end

  def current_network
    @current_network ||= Network.cached_find(params[:network_id].presence || params[:advertiser_id].presence)
  end

  def captured_at
    if postback_retrigger? && params[:captured_at].present?
      params[:captured_at].gsub('=', "\s")
    else
      Time.now.utc.to_s(:db)
    end
  end

  def process_custom_params_name(params)
    return params unless custom_params = current_network&.s2s_params.presence

    %w[server_subid order order_total revenue].each do |key|
      if custom_params[key] =~ /json_data/
        # Allow advertiser to post json data to be extracted
        param_json_data = CGI.unescape(params[:json_data])
        json_data =
          begin
            JSON.parse(param_json_data)
          rescue JSON::ParserError
          end
        next if json_data.blank?

        json_key = custom_params[key].split(':')[1]
        next if json_key.blank?

        params[key] = json_data[json_key]
      elsif custom_params[key].present?
        params[key] = interpolate_from_params(custom_params[key], params)
      end
    end

    params
  end

  def do_save_postback
    save_postback(@response, @stat_id)
  end
end
