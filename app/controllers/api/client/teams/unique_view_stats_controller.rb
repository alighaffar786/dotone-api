class Api::Client::Teams::UniqueViewStatsController < Api::Client::Teams::BaseController
  def index
    authorize! :read, UniqueViewStat
    report = DotOne::Reports::UniqueViewStat.new(current_ability, params.merge(current_options))
    @unique_view_stats, @total_applied, @total_active = report.generate
    @unique_view_stats = array_paginate(@unique_view_stats)
    respond_with_pagination @unique_view_stats, **instance_options
  end

  private

  def query_affiliates
    Affiliate
      .accessible_by(current_ability)
      .where(id: @unique_view_stats.map { |stat| stat[:affiliate_id] })
      .index_by(&:id)
  end

  def instance_options
    {
      meta: { total_applied: @total_applied, total_active: @total_active },
      affiliates: query_affiliates,
      each_serializer: Teams::UniqueViewStatSerializer,
    }
  end
end
