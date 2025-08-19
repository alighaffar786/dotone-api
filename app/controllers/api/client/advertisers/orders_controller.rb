class Api::Client::Advertisers::OrdersController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def update
    calculate

    @order.assign_attributes(order_params)
    if @order.save
      respond_with @order
    else
      respond_with @order, status: :unprocessable_entity
    end
  end

  private

  def calculate
    order_total = params.dig(:order, :total).presence
    order_total = order_total.present? ? [order_total.to_f, 0].max : @order.total
    @order.calculate(
      order_total: order_total,
      skip_existing_payout: true,
      skip_existing_commission: true,
      currency_code: current_currency_code,
    )
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
