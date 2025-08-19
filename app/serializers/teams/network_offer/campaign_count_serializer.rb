class Teams::NetworkOffer::CampaignCountSerializer < ApplicationSerializer
  attributes :offer_id, :count, :stats

  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer

  def stats
    return stat_template unless stats_data = instance_options[:stats].presence
    return stat_template unless found = stats_data[object.offer_id]

    stat_template.keys.each_with_object({}) do |month, result|
      result[month] = found&.find { |s| s.date == month }&.count.to_i
    end
  end

  def stat_template
    instance_options[:stat_template]
  end
end
