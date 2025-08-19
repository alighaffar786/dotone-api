class Ability::Affiliate < Ability::Base
  def user_rules
    can :create, AdSlot, when_mine.merge(text_creative: when_text_creatives_appliable)
    can :create, AdSlot, when_mine.merge(offers: { affiliate_offers: when_affiliate_offers_active.merge(when_mine) })
    can :create, AdSlot, when_mine.merge(category_groups: { categories: { text_creatives: when_text_creatives_appliable } })
    can [:read, :update, :destroy], AdSlot, when_ad_slots_active.merge(when_mine)

    can :manage, ::Affiliate, when_me
    cannot :refer, ::Affiliate
    can :refer, ::Affiliate, referrer_id: user.id
    can :refresh_token, ::Affiliate, when_me

    can :generate_ad_link, ::Affiliate

    can :manage, AffiliateAddress, when_mine

    can :manage, AffiliateApplication, when_mine

    can :read, AffiliateFeed, when_affiliate_feeds_active.merge(role: AffiliateFeed.role_affiliate)

    can :manage, AffiliateOffer, when_mine
    cannot :manage, AffiliateOffer, when_affiliate_offers_cancelled
    cannot :create, AffiliateOffer
    can :create, AffiliateOffer, default_offer_variant: when_offer_variants_active

    cannot :generate_url, AffiliateOffer
    can :generate_url, AffiliateOffer, when_affiliate_offers_active.merge(when_mine)

    can :read, AffiliatePaymentInfo, when_mine
    can :update, AffiliatePaymentInfo, when_mine.merge(when_affiliate_payment_info_pending)

    can :manage, AffiliatePayment, when_mine
    cannot :manage, AffiliatePayment, when_affiliate_payment_pending
    cannot :redeem, AffiliatePayment
    can :redeem, AffiliatePayment, when_mine.merge(when_affiliate_payment_redeemable)

    [AffiliateStat, Stat].each do |model|
      can :read, model, when_mine
      cannot :read, model, approval: AffiliateStat.approval_invalid
      can :read, model, when_mine.merge(approval: nil)
    end

    AffiliateStat::PARTITIONS.each do |model|
      can :read, model, when_mine.merge(when_stats_not_beyond_referral)
      can :read, model, when_mine.merge(when_stats_beyond_referral_acceptable)
      cannot :read, model, approval: AffiliateStat.approval_invalid
    end

    can :read, AffiliateUser, affiliates: when_me

    can :manage, ApiKey, when_owned

    can :read, AppConfig, active: true, role: AppConfig.role_affiliate

    can :read, ChatbotStep, role: ChatbotStep.role_affiliate

    can :manage, Download, when_owned

    can :read, FaqFeed, role: FaqFeed.role_affiliate, published: true

    can :manage, SiteInfo, when_mine

    can :read, EventOffer, when_event_offers_public
    can :read, EventOffer, when_event_offers_private.merge(affiliate_offers: when_with_event_affiliate_offer_approvals.merge(when_mine))
    cannot :read, EventOffer, when_event_offers_public.merge(offer_variants: when_offer_variants_private)
    cannot :read, EventOffer, offer_variants: when_offer_variants_negative

    can :read, ImageCreative, when_image_creatives_active.merge(offer_variants: when_offer_variants_active_public, internal: false)
    can :read, ImageCreative, when_image_creatives_active.merge(affiliate_offers: when_mine, internal: false)

    can :manage, MissingOrder, when_mine

    can :read, NetworkOffer, offer_variants: when_offer_variants_public.merge(is_default: true)
    can :read, NetworkOffer, affiliate_offers: when_mine.merge(
      approval_status: AffiliateOffer.approval_statuses(false),
      default_offer_variant: when_offer_variants_positive(true),
    )

    can :read, Order, when_mine
    can :read, OfferVariant, when_offer_variants_positive

    can :read, PartnerApp, visibility: PartnerApp.visibility_public

    can [:create, :verify, :resend_otp], PhoneVerification, when_owned
    can [:verify, :resend_otp], PhoneVerification, verified_at: nil

    can :read, PopupFeed, PopupFeed.active, &:active?

    can :read, Product

    can :read, TextCreative, when_text_creatives_active.merge(offer_variants: when_offer_variants_active_public)
    can :read, TextCreative, when_text_creatives_active.merge(affiliate_offers: when_mine)
    cannot :read, TextCreative, offer_variants: when_offer_variants_negative

    # TODO: Look into
    can :create, ChatRoom
    can :read, ChatRoom, chat_participations: when_chat_participant_is_me

    can [:read, :create], ChatMessage
  end

  private

  def when_mine
    { affiliate_id: user.id }
  end

  def when_text_creatives_appliable
    when_text_creatives_active.merge(affiliate_offers: when_affiliate_offers_active.merge(when_mine))
  end
end
