class Advertisers::OrderSerializer < Base::OrderSerializer
  attributes :id, :order_number, :status, :total, :recorded_at, :days_return, :days_since_order, :days_return_past_due?,
    :step_name, :step_label, :true_share, :true_pay, :conversion_step_snapshots, :offer_id, :affiliate_stat_id

  conditional_attributes :approval, if: :stat_serializer?

  def approval
    object.copy_stat&.approval.presence
  end

  def stat_serializer?
    [
      Advertisers::AffiliateStatSerializer,
      Advertisers::MissingOrderSerializer,
    ].include?(context_class)
  end

  def conversion_step_snapshots
    object.affiliate_stat.conversion_step_snapshots&.map do |values|
      values.except(:affiliate_pay, :affiliate_share, :affiliate_conv_type)
    end
  end
end
