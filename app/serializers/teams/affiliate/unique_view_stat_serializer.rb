class Teams::Affiliate::UniqueViewStatSerializer < Base::AffiliateSerializer
  attributes :id, :status, :ad_link_terms_accepted_at, :ad_link_installed_at, :ad_link_activated_at
end
