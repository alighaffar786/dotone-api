class Teams::Stat::ChannelSummarySerializer < ApplicationSerializer
  attributes :id, :total_affiliates_registered, :total_advertisers_registered, :clicks

  [:date, :channel_id, :campaign_id, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5].each do |column|
    attribute column, if: -> { column_requested?(column) }
  end

  has_one :channel, serializer: Teams::Channel::MiniSerializer, if: -> { column_requested?(:channel_id) }
  has_one :campaign, serializer: Teams::Campaign::MiniSerializer, if: -> { column_requested?(:campaign_id) }

  def channel
    return unless object.respond_to?(:channel_id)
    instance_options.dig(:channels, object.channel_id)
  end

  def campaign
    return unless object.respond_to?(:campaign_id)
    instance_options.dig(:campaigns, object.campaign_id)
  end

  def id
    current_columns.map { |column| object.send(column) }.join(',')
  end
end
