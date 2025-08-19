class Api::Client::Teams::OrdersController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @orders = paginate(query_index)
    respond_with_pagination @orders
  end

  def show
    respond_with @order
  end

  def create
    if @order.save
      respond_with @order
    else
      respond_with @order, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      respond_with @order, serializer: Teams::Order::UpdateSerializer
    else
      respond_with @order, status: :unprocessable_entity
    end
  end

  def finalize_cj
    if ClientApi.order_api.in_progress.exists?
      respond_with({ message: { ids: [DotOne::I18n.err('job_status_check.in_progress_order_pull')] } }, status: :unprocessable_entity)
    elsif JobStatusCheck.cj_finalize_in_progress?
      respond_with({ message: { ids: [DotOne::I18n.err('job_status_check.in_progress_cj')] } }, status: :unprocessable_entity)
    else
      ClientApis::OrderApi::CjFinalizeJob.perform_later(cj_order_params.to_h)

      head :ok
    end
  end

  private

  def query_index
    OrderCollection.new(@orders, params).collect
  end

  def order_params
    assign_local_time_params(order: [:recorded_at, :published_at, :converted_at])

    params.require(:order).permit(
      :affiliate_stat_id, :offer_id, :affiliate_id, :conversion_step_id, :status, :order_number, :true_share, :affiliate_share, :offer_variant_id,
      :total, :true_pay, :affiliate_pay,
      recorded_at_local: [], published_at_local: [], converted_at_local: []
    )
  end

  def cj_order_params
    params.require(:order).permit(:start_at, :end_at, :converted_at, :ids, :no_modification_on_final_status)
  end
end
