class Ability::AffiliateUser::OpsTeam < Ability::AffiliateUser::NetworkManager
  def user_rules
    super

    cannot :download, NetworkOffer
  end
end
