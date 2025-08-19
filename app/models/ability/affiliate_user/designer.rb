class Ability::AffiliateUser::Designer < Ability::AffiliateUser::Base
  def user_rules
    super

    affiliate_log_rules
    group_tag_rules(actions: :read)

    can :manage, [EventOffer, ImageCreative, TextCreative]

    can :manage, NetworkOffer
    cannot :download, NetworkOffer
  end
end
