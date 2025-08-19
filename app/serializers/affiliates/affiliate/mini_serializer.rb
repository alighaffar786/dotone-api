class Affiliates::Affiliate::MiniSerializer < Base::AffiliateSerializer
  attributes :id, :email, :name, :active?, :pending?, :avatar_cdn_url, :referral_tracking_url, :type, :profile_completed?,
    :country_id, :country_name, :age_confirmed, :accept_terms, :ad_link_terms_accepted_at

  def include_config?
    true
  end
end
