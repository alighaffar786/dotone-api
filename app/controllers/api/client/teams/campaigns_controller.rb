class Api::Client::Teams::CampaignsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @campaigns = paginate(query_index)
    respond_with_pagination @campaigns
  end

  def search
    authorize! :read, Campaign
    respond_with query_search, each_serializer: Teams::Campaign::SearchSerializer
  end

  def create
    if @campaign.save
      respond_with @campaign
    else
      respond_with @campaign, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      respond_with @campaign
    else
      respond_with @campaign, status: :unprocessable_entity
    end
  end

  private

  def query_index
    CampaignCollection.new(@campaigns, params).collect.preload(:channel)
  end

  def query_search
    CampaignCollection.new(current_ability, params).collect
  end

  def campaign_params
    params.require(:campaign).permit(:name, :channel_id, :destination_url)
  end
end
