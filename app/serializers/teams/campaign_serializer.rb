class Teams::CampaignSerializer < ApplicationSerializer
  attributes :id, :channel_id, :name, :created_at, :destination_url, :tracking_url

  has_one :channel

  def tracking_url
    object.to_tracking_url
  end
end
