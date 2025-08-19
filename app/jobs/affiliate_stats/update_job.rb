class AffiliateStats::UpdateJob < EntityManagementJob
  def perform(id, params)
    stat = AffiliateStat.find(id)

    DotOne::Utils::Rescuer.no_deadlock do
      stat.update(params)
    end
  end
end
