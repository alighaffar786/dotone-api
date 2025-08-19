class Affiliates::OrderSerializer < Base::OrderSerializer
  attributes :id, :order_number, :status, :total, :recorded_at, :days_return, :days_since_order, :days_return_past_due?,
    :affiliate_stat_id, :affiliate_pay
end
