class Teams::AdvertiserBalance::RemainingSerializer < Base::AdvertiserBalanceSerializer
  attributes :network_id, :final_balance, :pending_payout, :published_payout, :remaining_balance

  has_one :network, serializer: Teams::Network::MiniSerializer

  def pending_payout
    instance_options[:pending_payouts][object.network_id]&.pending_true_pay.to_f.round(2)
  end

  def published_payout
    instance_options[:published_payouts][object.network_id]&.published_true_pay.to_f.round(2)
  end

  def remaining_balance
    final_balance - pending_payout - published_payout
  end
end
