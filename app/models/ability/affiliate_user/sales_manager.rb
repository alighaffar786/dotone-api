class Ability::AffiliateUser::SalesManager < Ability::AffiliateUser::Base
  def user_rules
    super

    network_rules

    affiliate_log_rules
    sales_log_rules
    group_tag_rules(actions: :read)
    blog_tag_rules

    can :read, AffiliateOffer, offer: { network_id: managed_network_ids }

    can :read, [AffiliateStat, *AffiliateStat::PARTITIONS], network_id: managed_network_ids

    can :read, [Blog, BlogPage]
    can :manage, BlogContent, when_author
    can :manage, BlogImage

    can :manage, Campaign

    can :read, Channel

    can :manage, ContactList, owner_type: 'Network', owner_id: managed_network_ids

    can :read, ConversionStep, offer: { network_id: managed_network_ids }
    can :read, PaySchedule, owner_type: 'StepPrice', owner_id: StepPrice.where(conversion_step_id: ConversionStep.accessible_by(self))

    can :manage, Download, when_owned
    can :manage, Download, owner_type: 'Network', owner_id: managed_network_ids

    can :read, [EventOffer, NetworkOffer], network_id: managed_network_ids

    can :read, ImageCreative, offer: { network_id: managed_network_ids }

    can :download, Stat

    can :read, TextCreative, offer: { network_id: managed_network_ids }

    can :manage, Upload, when_owned
    can :manage, Upload, owner_type: 'Network', owner_id: managed_network_ids
  end

  def network_rules
    can [:read, :read_full], Network
    can [:create, :login_as], Network, when_network_assigned

    managed = Network.where(id: user.network_assignments.select(:network_id))
    awaiting = Network.considered_pending.where.not(id: AffiliateAssignment.network.select(:network_id))

    can :update, Network, when_recruited
    can [:recruit, :update], Network, id: managed.or(awaiting).pluck(:id)
  end
end
