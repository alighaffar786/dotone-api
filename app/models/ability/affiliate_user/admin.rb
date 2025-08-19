class Ability::AffiliateUser::Admin < Ability::AffiliateUser::Base
  def user_rules
    super
    can :manage, :all
    can [:login_as, :create_user, :read_user, :update_user, :destroy_user], ::AffiliateUser
    cannot [:update, :destroy], AlternativeDomain, visible: false
  end
end
