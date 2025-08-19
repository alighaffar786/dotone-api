class Teams::OrderSerializer < Base::OrderSerializer
  attributes :id, :affiliate_stat_id, :offer_id, :affiliate_id, :order_number, :status, :total,
    :recorded_at, :converted_at, :published_at

  conditional_attributes :conversion_step_id, :true_currency_code, :real_total, :affiliate_pay, :true_pay, :real_true_pay,
    :affiliate_share, :true_share, :step_label, :step_name, :days_return, :days_since_order, :days_return_past_due?,
    :approval, :single_conversion_point?, :conversion_step_snapshots, if: :full_scope?

  def approval
    object.copy_stat&.approval.presence
  end

  def single_conversion_point?
    object.offer.single_conversion_point?
  end

  def conversion_step_snapshots
    object.affiliate_stat.conversion_step_snapshots
  end
end
