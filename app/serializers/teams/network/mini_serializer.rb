class Teams::Network::MiniSerializer < Base::NetworkSerializer
  attributes :id

  conditional_attributes :full_name, :roles, if: :can_read_network?

  conditional_attributes :contact_email, :status, :billing_email, :payment_term, :payment_term_days,
    :universal_number, if: :for_stat?

  def for_stat?
    can_read_network? && [Teams::AffiliateStatSerializer, Teams::AffiliateStat::IndexSerializer].include?(context_class)
  end
end
