class Affiliates::AffiliateSerializer < Base::AffiliateSerializer
  attributes :id, :email, :business_entity, :first_name, :last_name, :name, :email, :avatar_cdn_url, :birthday, :email_verified, :nickname,
    :messenger_service, :messenger_service_2, :messenger_id, :messenger_id_2, :ad_link_terms_accepted_at, :ad_link_code,
    :google_id, :facebook_id, :line_id, :referral_tracking_url, :type, :active?, :pending?, :gender, :profile_completed?, :country_id, :country_name,
    :age_confirmed, :accept_terms, :company?, :tfa_enabled, :optout_from_offer_newsletter

  has_one :affiliate_address
  has_one :affiliate_application

  def include_config?
    true
  end
end
