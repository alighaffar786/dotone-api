class Ability::AffiliateUser::SalesDirector < Ability::AffiliateUser::Base
  def user_rules
    super

    affiliate_log_rules
    sales_log_rules
    group_tag_rules(actions: :read)
    blog_tag_rules

    can :read, AffiliateOffer

    can custom_actions(postfix: :event), AffiliateOffer, offer: when_event_offer

    can :read, [AffiliateStat, *AffiliateStat::PARTITIONS]

    can :read, AffiliateUser, when_sales_team

    can :read, Attachment, owner_type: 'Network'

    can :read, [Blog, BlogPage]
    can :manage, [BlogContent, BlogImage]

    can :manage, Campaign

    can :read, [Channel, ConversionStep, PaySchedule, NetworkOffer, ImageCreative, TextCreative]

    can :manage, ContactList, owner_type: 'Network'

    can :manage, Download, when_owned
    can :manage, Download, owner_type: 'Network'

    can :manage, EventOffer

    can :manage, Network

    can :download, Stat

    can :manage, Upload, when_owned
    can :manage, Upload, owner_type: 'Network'
  end
end
