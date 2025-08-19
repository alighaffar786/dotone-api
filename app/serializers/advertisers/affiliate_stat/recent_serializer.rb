class Advertisers::AffiliateStat::RecentSerializer < Base::AffiliateStatSerializer
  class OrderSerializer < Base::OrderSerializer
    attributes :id, :order_number
  end

  attributes :transaction_id, :captured_at, :converted_at, :step_label, :affiliate_pay, :approval, :affiliate_id, :true_pay

  has_one :copy_order, key: :order, serializer: OrderSerializer
  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
end
