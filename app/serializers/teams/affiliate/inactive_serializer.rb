class Teams::Affiliate::InactiveSerializer < Base::AffiliateSerializer
  attributes :id, :current_balance, :last_request_at
end
