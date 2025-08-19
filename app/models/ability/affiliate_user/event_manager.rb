class Ability::AffiliateUser::EventManager < Ability::AffiliateUser::AffiliateDirector
  def user_rules
    super

    can custom_actions(postfix: :event), AffiliateOffer, offer: when_event_offer

    can :manage, EventOffer
  end
end
