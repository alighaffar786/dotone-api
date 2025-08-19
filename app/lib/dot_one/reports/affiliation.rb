# frozen_string_literal: true

class DotOne::Reports::Affiliation < DotOne::Reports::Base
  attr_reader :ability, :date_range, :offer_ids, :network_ids

  def initialize(user, params = {})
    @ability = user.is_a?(Ability) ? user : Ability.new(user)
    @start_date = params[:start_date].presence || Date.today
    @end_date = params[:end_date].presence || Date.today
    @date_range = [@start_date, @end_date]
    @offer_ids = params[:offer_ids]
    @network_ids = params[:network_ids]
    super(params)
  end

  def query_stats
    Stat
      .accessible_by(ability)
      .with_offers(offer_ids)
      .with_networks(network_ids)
  end

  def query_affiliate_offers
    AffiliateOffer
      .accessible_by(ability)
      .joins(:offer)
      .where(offers: { type: 'NetworkOffer' })
      .with_offers(offer_ids)
      .with_networks(network_ids)
      .with_approval_statuses(AffiliateOffer.approval_status_considered_approved)
  end

  def clicks_counts
    @clicks_counts ||= DotOne::Cache.fetch(cache_key_name(:clicks_counts), expires_in: 30.minutes) do
      query_stats
        .stat([:offer_id], [:clicks], user_role: ability.user_role)
        .between(*date_range, :recorded_at, time_zone)
        .to_h { |stat| [stat.offer_id, stat.clicks] }
    end
  end

  def captured_counts
    @captured_counts ||= DotOne::Cache.fetch(cache_key_name(:captured_counts), expires_in: 30.minutes) do
      query_stats
        .stat([:offer_id], [:captured], user_role: ability.user_role)
        .between(*date_range, :captured_at, time_zone)
        .to_h { |stat| [stat.offer_id, stat.captured] }
    end
  end

  def applied_counts
    @applied_counts ||= DotOne::Cache.fetch(cache_key_name(:applied_counts), expires_in: 30.minutes) do
      query_affiliate_offers
        .between(*date_range, :created_at, time_zone)
        .group(:offer_id)
        .count
    end
  end

  def total_applied_counts
    @total_applied_counts ||= DotOne::Cache.fetch(cache_key_name(:total_applied_counts), expires_in: 30.minutes) do
      query_affiliate_offers
        .group(:offer_id)
        .count
    end
  end

  def generate
    all_offer_ids = NetworkOffer
      .joins(:default_offer_variant)
      .where(id: clicks_counts.keys | captured_counts.keys | total_applied_counts.keys)
      .pluck('offers.id, offer_variants.status as status')

    result = all_offer_ids.map do |offer_id, status|
      AffiliationStat.new(
        status_index: OfferVariant.statuses.find_index(status),
        offer_id: offer_id,
        clicks: clicks_counts[offer_id].to_i,
        captured: captured_counts[offer_id].to_i,
        applied: applied_counts[offer_id].to_i,
        total_applied: total_applied_counts[offer_id].to_i,
      )
    end

    result.sort_by { |stat| [stat.status_index, stat.applied * -1] }
  end

  def total
    {
      clicks: clicks_counts.values.sum,
      captured: captured_counts.values.sum,
      applied: applied_counts.values.sum,
      total_applied: total_applied_counts.values.sum,
    }
  end

  private

  class AffiliationStat < ::AffiliateStat
    attr_accessor :applied, :total_applied, :clicks, :captured, :status_index
  end

  def cache_key_name(*keys)
    super([*keys, *date_range, *offer_ids, *network_ids])
  end
end
