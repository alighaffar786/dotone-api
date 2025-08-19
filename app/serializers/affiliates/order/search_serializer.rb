class Affiliates::Order::SearchSerializer < Base::OrderSerializer
  attributes :id, :order_number, :total, :currency_id

  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer

  def currency_id
    object.conversion_step&.true_currency_id
  end
end
