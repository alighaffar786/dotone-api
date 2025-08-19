module Relations::CampaignAssociated
  extend ActiveSupport::Concern
  include Scopeable

  included do
    belongs_to :campaign, inverse_of: self.name.tableize

    scope_by_campaign
  end

  def cached_campaign
    Campaign.cached_find(campaign_id)
  end
end
