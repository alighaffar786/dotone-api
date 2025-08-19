class Teams::AffiliateStat::ConversionSerializer < Base::AffiliateStatSerializer
  class OrderSerializer < Base::OrderSerializer
    attributes :id, :order_number, :true_share, :affiliate_share, :days_return, :days_since_order,
      :days_return_past_due?, :status
  end

  attributes :id, :transaction_id, :copy_stat_id, :recorded_at, :captured_at, :published_at, :converted_at,
    :order_total, :true_pay, :affiliate_pay, :calculated_margin, :step_name, :step_label, :approval,
    :single_point?, :multi_point?

  has_one :copy_order, key: :order, serializer: OrderSerializer
end
