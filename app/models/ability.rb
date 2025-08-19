# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user, :user_role

  def initialize(user)
    @user = user
    @user_role = user&.generic_role
    user ? user_rules : guest_rules
  end

  def ability
    @ability ||= "Ability::#{user.class.name}".constantize.new(user)
  end

  def user_rules
    public_rules
    merge(ability)
    can :create, :search_key
  end

  def rules_description
    ability.try(:rules_description)
  end

  def public_rules
    can :read, AffiliateTag
    can :read, AlternativeDomain
    can :read, Category
    can :read, CategoryGroup
    can :read, Country
    can :read, Currency
    can :read, Expertise
    can :read, Language
    can :read, MktSite
    can :read, TimeZone
    can :read, EventOffer, event_info: { is_private: false }, offer_variants: { status: OfferVariant.status_considered_active_public }
    can :read, ProductCategory
  end

  def guest_rules
    can [:login, :create_password, :reset_password, :signup, :verify], ::Affiliate
    can [:login, :create_password, :reset_password, :signup, :verify], ::Network
    can [:login, :create_password, :reset_password], ::AffiliateUser

    public_rules
  end
end
