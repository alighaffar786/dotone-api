class Api::Client::Affiliates::OrdersController < Api::Client::Affiliates::BaseController
  def search
    authorize! :read, Order
    @orders = query_search
    respond_with @orders, each_serializer: Affiliates::Order::SearchSerializer
  end

  private

  def query_search
    OrderCollection.new(current_ability, params)
      .collect
      .preload(:conversion_steps, offer: :name_translations)
  end
end
