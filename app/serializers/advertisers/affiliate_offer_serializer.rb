class Advertisers::AffiliateOfferSerializer < Base::AffiliateOfferSerializer
  attributes :id, :offer_id, :approval_status, :created_at, :default_payouts, :custom_payouts,
    :approval_status_changed_at

  has_many :network_logs, key: :logs

  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
  has_one :affiliate, serializer: Advertisers::AffiliateSerializer

  def default_payouts
    object.default_conversion_step&.payout_details(currency_code)
  end

  def custom_payouts
    object.default_step_price&.payout_details(currency_code)
  end

  def network_logs
    object.network_logs.select { |log| [nil, current_user.id].include?(log.agent_id) }
  end
end
