class Ability::AffiliateUser::Base < Ability::Base
  def user_rules
    can :manage, ::AffiliateUser, when_me
    cannot [:login_as, :create_user, :read_user, :update_user, :destroy_user], ::AffiliateUser

    # TODO: Look into
    can :create, ChatRoom
    can :read, ChatRoom, chat_participations: when_chat_participant_is_me

    can [:read, :create], ChatMessage

    cannot custom_actions(postfix: :parking), Category

    can :read, Stat
  end

  def affiliate_log_rules
    can :manage, AffiliateLog, when_agent
    cannot [:sales_summary, :sales_logs], AffiliateLog
  end

  def sales_log_rules
    can [:sales_summary, :sales_logs], AffiliateLog, owner_type: 'Network', agent_type: 'AffiliateUser'
  end

  def group_tag_rules(actions: :manage)
    custom_actions(actions: actions, postfix: :group).each do |action|
      can action, AffiliateTag, when_group_tag
    end
  end

  def blog_tag_rules(actions: :manage)
    custom_actions(actions: actions, postfix: :blog).each do |action|
      can action, AffiliateTag, when_blog_tag
    end
  end

  def when_affiliate_assigned
    { affiliate_assignments: { affiliate_user_id: user.id } }
  end

  def when_network_assigned
    { network_assignments: { affiliate_user_id: user.id } }
  end

  def when_recruited
    { recruiter_id: user.id }
  end

  def when_affiliate_team
    { roles: AffiliateUser.affiliate_team_roles }
  end

  def when_sales_team
    { roles: AffiliateUser.sales_team_roles }
  end

  def managed_affiliate_ids
    @managed_affiliate_ids ||= Affiliate.accessible_by(self, :update).pluck(:id)
  end

  def managed_network_ids
    @managed_network_ids ||= Network.accessible_by(self, :update).pluck(:id)
  end

  def custom_actions(actions: :manage, postfix:)
    if actions == :manage
      actions = [:read, :create, :update, :destroy]
    else
      actions = [actions].flatten
    end

    actions.map { |action| "#{action}_#{postfix}".to_sym }
  end
end
