class Api::Client::Teams::BotStatsController < Api::Client::Teams::BaseController
  include Api::Client::AffiliateStatsHelper

  def index
    authorize! :read, BotStat
    @bot_stats = paginate(query_index)
    respond_with_pagination @bot_stats, **instance_options
  end

  private

  def query_index
    collection = BotStatCollection.new(current_ability, params, **current_options).collect
    collection.preload(:affiliate, offer: [:name_translations])
  end

  def instance_options
    {
      clicks: true,
      each_serializer: Teams::AffiliateStat::IndexSerializer,
    }
  end
end
