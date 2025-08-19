class Api::Client::Teams::MissingOrdersController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @missing_orders = paginate(query_index)
    respond_with_pagination @missing_orders
  end

  def update
    if @missing_order.update(missing_order_params)
      @missing_order.process_stat_conversion if @missing_order.order_added?

      respond_with @missing_order.reload
    else
      respond_with @missing_order, status: :unprocessable_entity
    end
  end

  private

  def query_index
    MissingOrderCollection.new(current_ability, params, **current_options)
      .collect
      .preload(
        :currency, :screenshot, :affiliate, order: :copy_stat,
        offer: [:name_translations, :default_conversion_step]
      )
  end

  def missing_order_params
    assign_local_time_params({ missing_order: [:click_time, :order_time] })

    params
      .require(:missing_order)
      .permit(
        :status, :status_summary, :status_reason, :order_total, :click_time, :order_time, :true_pay,
      )
      .tap do |param|
        param[:status] = MissingOrder.status_rejected_by_admin if MissingOrder.status_considered_rejected.include?(param[:status])
      end
  end
end
