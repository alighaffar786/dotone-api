class Base::AffiliateSerializer < ApplicationSerializer
  local_time_attributes(*Affiliate.local_time_attributes)
  translatable_attributes(*Affiliate.static_translatable_attributes)
  maskable_attributes(*Affiliate.maskable_attributes)

  user_config_attributes

  attribute :name, if: :can_read_affiliate?

  def can_read_affiliate?
    pro_network? || network? && object.direct? || !network? && super
  end

  def can_read?
    can_read_affiliate?
  end

  def referral_tracking_url
    object.to_referral_tracking_url
  end

  def profile_completed?
    object.gender.present? && object.birthday.present? && object.country.present?
  end

  def country_id
    object.country&.id
  end

  def country_name
    object.country&.t_name(object.locale)
  end

  def age_confirmed
    object.affiliate_application&.age_confirmed
  end

  def accept_terms
    object.affiliate_application&.accept_terms
  end

  def name
    object.full_name
  end
end
