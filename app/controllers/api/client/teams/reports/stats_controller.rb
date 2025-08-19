class Api::Client::Teams::Reports::StatsController < Api::Client::Teams::BaseController
  def channel_summary
    authorize! :read, Stat
    @stats = paginate(query_channel_stats)
    respond_with_pagination @stats, each_serializer: Teams::Stat::ChannelSummarySerializer, channels: query_channels, campaigns: query_campaigns
  end

  private

  def query_channel_stats
    start_date = params[:start_date] || Date.today
    end_date = params[:end_date] || Date.today

    Stat
      .accessible_by(current_ability)
      .stat(
        current_columns,
        [:clicks, :total_advertisers_registered, :total_affiliates_registered],
        user_role: :owner,
        date_type: :recorded_at,
        time_zone: current_time_zone,
        sort_field: params[:sort_field] || :clicks,
        sort_order: params[:sort_order] || :desc
      )
      .clicks
      .has_channel
      .with_channels(params[:channel_ids])
      .with_campaigns(params[:campaign_ids])
      .between(start_date, end_date, :recorded_at, current_time_zone)
  end

  def query_channels
    return {} unless current_columns.include?(:channel_id)

    Channel.where(id: @stats.map(&:channel_id)).index_by(&:id)
  end

  def query_campaigns
    return {} unless current_columns.include?(:campaign_id)

    Campaign.where(id: @stats.map(&:campaign_id)).index_by(&:id)
  end
end
