# Collection of ability/authorization for Network role
class Ability::Network < Ability::Base
  def user_rules
    can :read, AdvertiserBalance, when_mine

    can [:read, :update], Affiliate, {
      offers: when_mine,
      status: [Affiliate.status_active, Affiliate.status_paused, Affiliate.status_suspended],
    }

    can :read, AffiliateFeed, when_affiliate_feeds_active.merge(role: [AffiliateFeed.role_network, AffiliateFeed.role_affiliate])

    can :read, AffiliateLog, agent_type: 'Network', agent_id: nil
    can :manage, AffiliateLog, when_agent

    can :read, AffiliateOffer, when_affiliate_offers_applicable
    can :update, AffiliateOffer, when_affiliate_offers_applicable if user.pro?

    can :manage, AffiliateStat, when_mine

    AffiliateStat::PARTITIONS.each do |model|
      can :manage, model, when_mine
    end

    can :read, AffiliateUser, networks: when_me, status: AffiliateUser.status_active

    can :manage, ApiKey, when_owned

    can :read, AppConfig, active: true, role: AppConfig.role_network

    can :read, ChatbotStep, role: ChatbotStep.role_network

    can :manage, ContactList, when_owned.merge(status: ContactList.status_active)

    can :manage, Download, when_owned

    can :read, FaqFeed, role: FaqFeed.role_network, published: true

    can :manage, ImageCreative, offer_variants: when_offer_variants_active.merge(offer: when_mine)

    can [:read, :update], MissingOrder, status: MissingOrder.statuses(:network), offer: when_mine

    cannot :read, MktSite
    can :read, MktSite, when_mine

    can :refresh_token, Network, when_me
    can :manage, Network, when_me

    can :read, NetworkOffer, when_mine

    unless DotOne::Setup.tracking_server?
      can [:read, :update], ClientApi, owner_type: 'Offer', api_type: ClientApi.api_type_product_api, owner_id: NetworkOffer.accessible_by(self).pluck(:id)
      can :create, ClientApi, owner_type: 'Offer', api_type: ClientApi.api_type_product_api
    end

    can :read, OfferStat

    can :read, Order, when_mine
    can :update, Order, when_mine.merge(status: [Order.status_pending, Order.status_rejected, Order.status_full_return, Order.status_invalid])

    can :read, OfferVariant, offer: when_mine

    can :read, Product, offer_id: NetworkOffer.accessible_by(self)

    can :read_impression, SiteInfo, { affiliate: { offers: when_mine } } if user.pro?

    can :read, Stat, when_mine

    can :manage, TextCreative, offer_variants: when_offer_variants_active.merge(offer: when_mine)

    can :manage, Upload, when_owned

    # TODO: Look into
    can :manage, Charge, when_mine
    can :manage, CreditCard, network: when_me

    can :create, ChatRoom
    can :read, ChatRoom, chat_participations: when_chat_participant_is_me

    can [:read, :create], ChatMessage

    can :manage, EasyStoreSetup, when_mine
  end

  private

  def when_mine
    { network_id: user.id }
  end

  def when_affiliate_offers_applicable
    {
      approval_status: [
        user.partial_pro? ? AffiliateOffer.approval_status_confirming : AffiliateOffer.approval_status_pending,
        AffiliateOffer.approval_status_active,
        AffiliateOffer.approval_status_paused,
        AffiliateOffer.approval_status_suspended,
      ],
      offer: when_mine.merge(when_network_offer),
    }
  end
end
