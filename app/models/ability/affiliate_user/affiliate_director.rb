class Ability::AffiliateUser::AffiliateDirector < Ability::AffiliateUser::Base
  def user_rules
    super

    affiliate_log_rules
    group_tag_rules(actions: :read)
    blog_tag_rules

    can :manage, Affiliate

    can :read, AffiliateOffer

    can :read, [AffiliateStat, *AffiliateStat::PARTITIONS]

    can :read, AffiliateUser, when_affiliate_team

    can :manage, AffiliateProspect

    can :read, Attachment, owner_type: 'Affiliate'

    can :read, [Blog, BlogPage]
    can :manage, [BlogContent, BlogImage]

    can :manage, Campaign

    can :read, [Channel, ConversionStep, PaySchedule, EventOffer, NetworkOffer, ImageCreative, TextCreative]

    can :manage, ContactList, owner_type: 'Affiliate'

    can :manage, Download, when_owned
    can :manage, Download, owner_type: 'Affiliate'

    can :manage, SiteInfo

    can :manage, Upload, when_owned
    can :manage, Upload, owner_type: 'Affiliate'
  end
end
