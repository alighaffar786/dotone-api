class Api::V2::Advertisers::OrdersController < Api::V2::Advertisers::BaseController
  include Track::ConversionHandler

  skip_authorization_check only: :nine_one_app
  after_action :do_save_postback, :record_pixel_usage

  def modify
    authorize! :update, AffiliateStat
    validate_ip
    handle_conversion
  rescue DotOne::Errors::BaseError
    @result = { status: 'Error', message: "You are not authorized. #{request.remote_ip} must be whitelisted" }
    status_code = :unauthorized
    respond_with @result, status: status_code
  end

  def nine_one_app
    handle_conversion
  end

  private

  def require_params
    send("require_params_#{params[:action]}")
  end

  def require_params_modify
    params.require(:status)

    return unless params[:status] == 'adjust'

    params.require(:revenue) if params[:order_total].blank?
    params.require(:order_total) if params[:revenue].blank?
  end

  def require_params_nine_one_app
    params.require(:osc)
    params.require(:ti)
    params.require(:oid)
    params.require(:prtp) if params[:osc] == 'create'
  end

  def order_params
    @order_params ||= begin
      parameters =
        case action_name.to_sym
        when :modify
          params
            .permit(:server_subid, :offer_id, :order, :step, :status, :order_total, :revenue)
            .merge(network: current_user)
        when :nine_one_app
          params[:status] = params.delete(:osc)
          params[:order] = [params.delete(:ti), params.delete(:oid)].compact.join(':')
          params[:server_subid] = params.delete(:tripid)
          params[:order_total] = params.delete(:prtp)
          params
            .permit(:status, :server_subid, :order, :order_total)
            .merge(flexible: true)
        end

      parameters.to_h.symbolize_keys
    end
  end

  def validate_ip
    ips = [
      *whitelisted_ips,
      *current_user.ip_address_white_listed_array,
      *current_user.authorized_ips_from_dns,
    ].flatten.compact

    raise DotOne::Errors::BaseError unless ips.include?(request.remote_ip)
  end

  def handle_conversion
    @result = { status: nil, message: nil }
    @handler = DotOne::AffiliateStats::OrderApiHandler.new(**order_params)

    if @handler.valid?
      conversion_result = @handler.save

      if conversion_result[:convert] == true
        @result[:status] = 'Success'
        status_code = :ok
      else
        @result[:status] = 'Error'
        @result[:message] = conversion_result[:errors]
        status_code = :unprocessable_entity
      end
    else
      order_params[:network_id] = order_params.delete(:network)&.id
      AffiliateStats::OrderApiHandlerJob.perform_later(**order_params) if @handler.delay?

      @result[:message] = @handler.errors.full_messages
      @result[:status] = 'Error'
      status_code = :unprocessable_entity
    end

    respond_with @result, status: status_code
  end

  def do_save_postback
    save_postback(@result, @handler&.click_stat&.id || params[:server_subid])
  end

  def record_pixel_usage
    return if @handler&.offer.blank?

    pixel = OfferConversionPixel.api.where(offer_id: @handler.offer.id).first_or_initialize
    pixel.persisted? ? pixel.touch : pixel.save
  end
end
