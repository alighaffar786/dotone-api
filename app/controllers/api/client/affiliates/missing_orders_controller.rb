class Api::Client::Affiliates::MissingOrdersController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    @missing_orders = paginate(query_index)
    respond_with_pagination @missing_orders
  end

  def create
    if @missing_order.save
      respond_with @missing_order
    else
      respond_with @missing_order, status: :unprocessable_entity
    end
  end

  private

  def query_index
    MissingOrderCollection.new(current_ability, params, **current_options)
       .collect
       .preload(:currency, :screenshot, order: :copy_stat, offer: :name_translations)
  end

  def missing_order_params
    assign_local_time_params(missing_order: MissingOrder.local_time_attributes)

    params.require(:missing_order).permit(
      :offer_id, :order_id, :currency_id, :question_type, :order_number, :order_total, :payment_method,
      :device, :notes, :screenshot_cdn_url, order_time_local: [], click_time_local: []
    )
  end
end
