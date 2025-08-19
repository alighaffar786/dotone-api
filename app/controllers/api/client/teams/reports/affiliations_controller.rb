class Api::Client::Teams::Reports::AffiliationsController < Api::Client::Teams::BaseController
  def index
    authorize! :read_affiliation, Stat
    @stats, @total = query_index
    @stats = array_paginate(@stats)
    respond_with_pagination @stats, offers: query_offers, meta: { total: @total }
  end

  private

  def query_index
    report = DotOne::Reports::Affiliation.new(current_ability, params.merge(current_options))
    [report.generate, report.total]
  end

  def query_offers
    NetworkOffer
      .where(id: @stats.map(&:offer_id))
      .preload(:default_offer_variant, :name_translations)
      .index_by(&:id)
  end
end
