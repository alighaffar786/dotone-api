class Ability::AffiliateUser::AffiliateManager < Ability::AffiliateUser::Base
  def user_rules
    super

    affiliate_rules

    affiliate_log_rules
    group_tag_rules(actions: :read)
    blog_tag_rules

    can :read, AffiliateOffer, affiliate_id: managed_affiliate_ids

    can :read, [AffiliateStat, *AffiliateStat::PARTITIONS], affiliate_id: managed_affiliate_ids

    can :manage, AffiliateProspect, recruiter_id: user.id

    can :read, [Blog, BlogPage]
    can :manage, BlogContent, when_author
    can :manage, BlogImage

    can :manage, Campaign

    can :read, [Channel, ConversionStep, PaySchedule, EventOffer, NetworkOffer, ImageCreative, TextCreative]

    can :manage, ContactList, owner_type: 'Affiliate', owner_id: managed_affiliate_ids

    can :manage, Download, when_owned
    can :manage, Download, owner_type: 'Affiliate', owner_id: managed_affiliate_ids

    can :manage, SiteInfo, affiliate_id: managed_affiliate_ids

    can :manage, Upload, when_owned
    can :manage, Upload, owner_type: 'Affiliate', owner_id: managed_affiliate_ids
  end

  def affiliate_rules
    can [:read, :read_full], Affiliate

    managed = Affiliate.where(id: user.affiliate_assignments.select(:affiliate_id))
    awaiting = Affiliate.considered_pending.where.not(id: AffiliateAssignment.affiliate.select(:affiliate_id))

    can :update, Affiliate, when_recruited
    can [:recruit, :update], Affiliate, id: managed.or(awaiting).pluck(:id)
  end
end
