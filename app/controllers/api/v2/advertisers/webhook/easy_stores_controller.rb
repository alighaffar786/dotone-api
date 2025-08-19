class Api::V2::Advertisers::Webhook::EasyStoresController < Api::V2::Advertisers::BaseController
  include Track::ConversionHandler

  before_action :validate_hmac,
    :set_result,
    :validate_and_set_order

  after_action :do_save_postback

  rescue_from DotOne::Errors::BaseError, with: :handle_error

  def update
    subtotal_after_discount = order_params[:subtotal_price].to_f - order_params[:total_discount].to_f
    subtotal_price = [subtotal_after_discount, order_params[:currency]]

    @order.forex_total = subtotal_price
    @order.calculate(
      order_total: @order.total,
      skip_currency_adjustment: true,
    )
    @order.trace_custom_agent = trace_custom_agent

    if @order.save
      @result[:status] = 'Success'
    else
      @result[:status] = 'Error'
      @result[:messages] = @order.errors.full_messages.join(',')
      status_code = 400
    end

    respond_with @result, status_code: status_code
  end

  def reject
    @order.status = AffiliateStat.approval_rejected
    @order.trace_custom_agent = trace_custom_agent

    if @order.save
      @result[:status] = 'Success'
      status_code = :ok
    else
      @result[:status] = 'Error'
      @result[:messages] = ['Failed to reject order']
      @result[:errors] = @order.errors.full_messages
      status_code = :unprocessable_entity
    end

    respond_with @result, status_code: status_code
  end

  private

  def set_result
    @result = {
      status: nil,
      errors: [],
      messages: [],
    }
  end

  def handle_error(error)
    result = {
      status: 'Error',
      errors: [error.message],
      messages: [error.full_message],
    }

    respond_with result, status: 400
  end

  def validate_hmac
    return true if Rails.env.development?

    hmac = request.headers['EasyStore-Hmac-SHA256']
    message = JSON.parse(request.raw_post).to_json rescue ''
    verified = DotOne::ApiClient::ApiWorker::EasyStore.hmac_valid?(hmac, message)
    result = { status: 'Error', errors: 'Invalid header' }

    respond_with result, status: 400 and return unless verified
  end

  def validate_and_set_order
    authorize! :webhook, EasyStoreSetup

    adv_uniq_id = params[:token] || params.dig(:order, :token)
    @current_stat = AffiliateStat.with_adv_uniq_ids(adv_uniq_id).first

    raise DotOne::Errors::InvalidDataError.new(adv_uniq_id, 'data.unknown_transaction') if @current_stat.blank?

    authorize! :update, @current_stat

    @order = @current_stat.copy_order

    raise DotOne::Errors::InvalidDataError.new(adv_uniq_id, 'data.missing_order', 'token') if @order.blank?
    raise DotOne::Errors::TransactionError::FinalStateModificationError, @current_stat.error_payload if @current_stat.considered_final?(:network)
  end

  def order_params
    params.require(:order)
      .permit(:subtotal_price, :total_discount, :currency)
  end

  def trace_custom_agent
    ["EasyStore", store_domain, request.headers['easystore-topic']].compact_blank.join(' - ')
  end

  def store_domain
    request.headers['easystore-shop-domain']
  end

  def easy_store_setup
    @easy_store_setup ||= EasyStoreSetup.find_by(store_domain: store_domain)
  end

  def current_user
    @current_user ||= easy_store_setup&.network
  end

  def do_save_postback
    save_postback(@result, @current_stat&.id)
  end

  def meta_options
    {}
  end
end
