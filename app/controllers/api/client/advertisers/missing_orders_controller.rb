class Api::Client::Advertisers::MissingOrdersController < Api::Client::Advertisers::BaseController

  load_and_authorize_resource except: :download

  def index
    @missing_orders = paginate(query_index)
    respond_with_pagination @missing_orders
  end

  def update
    @missing_order.do_update_amounts = true
    @missing_order.assign_attributes(missing_order_params)

    if @missing_order.save
      @missing_order.reload if @missing_order.process_stat_conversion

      respond_with @missing_order
    else
      respond_with @missing_order, status: :unprocessable_entity
    end
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download

    if @download.save
      start_download_job(@download)
      respond_with @download, status: :ok
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_index
    MissingOrderCollection.new(current_ability, params, **current_options)
      .collect
      .preload(
        :currency, :screenshot, order: [:copy_stat, :offer, :conversion_steps],
        offer: [:name_translations, ordered_conversion_steps: [:label_translations, :active_pay_schedule, :true_currency]]
      )
  end

  def missing_order_params
    assign_forex_value_params(missing_order: [:true_pay, :order_total])

    params.require(:missing_order).permit(
      :status, :status_summary, :status_reason, forex_true_pay: [], forex_order_total: []
    ).tap do |param|
      param[:status] = MissingOrder.status_rejected_by_advertiser if MissingOrder.status_considered_rejected.include?(param[:status])
    end
  end
end
