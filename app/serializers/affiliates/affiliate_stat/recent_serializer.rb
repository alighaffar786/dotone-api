class Affiliates::AffiliateStat::RecentSerializer < Base::AffiliateStatSerializer
  class OrderSerializer < Base::OrderSerializer
    attributes :id, :order_number
  end

  attributes :transaction_id, :captured_at, :converted_at, :step_label, :affiliate_pay, :approval

  has_one :copy_order, key: :order, serializer: OrderSerializer
  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer
end
