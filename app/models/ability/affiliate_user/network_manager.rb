class Ability::AffiliateUser::NetworkManager < Ability::AffiliateUser::Base
  def user_rules
    super

    affiliate_log_rules
    sales_log_rules
    group_tag_rules
    blog_tag_rules

    can :manage, [
      AdvertiserBalance,
      Affiliate,
      AffiliateFeed,
      AffiliateOffer,
      AffiliatePayment,
      AffiliateProspect,
      AffiliatePaymentInfo,
      AppConfig,
      ApiKey,
      Attachment,
      Blog,
      BlogContent,
      BlogImage,
      BlogPage,
      Campaign,
      Channel,
      ClickAbuseReport,
      ClientApi,
      ChatbotStep,
      ContactList,
      ConversionStep,
      Delayed::Job,
      Download,
      EventOffer,
      FaqFeed,
      ImageCreative,
      JobStatusCheck,
      MktSite,
      Network,
      NetworkOffer,
      OfferVariant,
      Order,
      OwnerHasTag,
      PaySchedule,
      PopupFeed,
      Postback,
      SiteInfo,
      Snippet,
      Term,
      TextCreative,
      Upload,
      VtmChannel,
    ]

    can :read, AffiliateSearchLog

    can :manage, [AffiliateStat, *AffiliateStat::PARTITIONS]

    can :read, AffiliateUser

    can :manage, AlternativeDomain
    cannot [:update, :destroy], AlternativeDomain, visible: false

    can :read_parking, Category

    can :read, ChatbotSearchLog

    can [:read, :update], MissingOrder

    can :manage, Newsletter, role: Newsletter.roles

    can :read, SkinMap

    can [:read, :read_affiliation, :download], Stat

    can :read, UniqueViewStat

    can :read, :link_tracer
    can :create, :tracking_link
  end
end
