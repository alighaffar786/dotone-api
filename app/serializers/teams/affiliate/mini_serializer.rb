class Teams::Affiliate::MiniSerializer < Base::AffiliateSerializer
  attributes :id

  conditional_attributes :email, :status, :traffic_quality_level, :full_name, :roles, if: :can_read_affiliate?
  conditional_attributes :affiliate_user_ids, :recruiter_id, :recruited_at, if: :for_affiliate_offer?

  has_many :affiliate_users, serializer: Teams::AffiliateUser::MiniSerializer, if: :for_affiliate_offer?
  has_many :group_tags, if: :include_group_tags?
  has_many :site_infos, serializer: Teams::SiteInfo::MiniSerializer, if: :include_site_infos?

  has_one :recruiter, serializer: Teams::AffiliateUser::MiniSerializer, if: :for_affiliate_offer?

  def for_affiliate_offer?
    context_class == Teams::AffiliateOfferSerializer
  end

  def for_event_affiliate_offer?
    context_class == Teams::EventAffiliateOfferSerializer
  end

  def include_group_tags?
    can_read_affiliate? && (for_affiliate_offer? || for_event_affiliate_offer?)
  end

  def include_site_infos?
    can_read_affiliate? && context_class == Teams::Stat::AffiliatePerformanceSerializer
  end
end
