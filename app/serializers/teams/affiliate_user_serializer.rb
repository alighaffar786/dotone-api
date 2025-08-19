class Teams::AffiliateUserSerializer < Base::AffiliateUserSerializer
  attributes :id, :title, :roles, :username, :status, :avatar_cdn_url, :first_name, :last_name, :full_name,
    :direct_phone, :mobile_phone, :fax, :email, :line, :skype, :wechat, :qq, :rules, :director?, :manager?, :upper_team?,
    :tfa_enabled

  def rules
    return unless object.id == current_user.id

    current_ability.rules_description
  end

  def include_config?
    object.id == current_user.id
  end
end
