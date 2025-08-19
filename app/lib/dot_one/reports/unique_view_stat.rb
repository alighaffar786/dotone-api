class DotOne::Reports::UniqueViewStat < DotOne::Reports::Base
  attr_accessor :date_range, :date_range_applied, :date_range_activated, :affiliate_ids, :ability, :params

  def initialize(user, params = {})
    super(params)
    @params = params
    @date_range = [params[:start_date], params[:end_date]].map { |date| date&.to_date || Date.today }
    @date_range_applied = [params[:applied_start_date], params[:applied_end_date]].compact
    @date_range_activated = [params[:activated_start_date], params[:activated_end_date]].compact
    @affiliate_ids = params[:affiliate_ids]
    @ability = user.is_a?(Ability) ? user : Ability.new(user)
  end

  def generate
    super do
      stats = query_stats.map do |affiliate_id, stat|
        {
          affiliate_id: affiliate_id,
          clicks: 0,
          impressions: 0,
          captured: 0,
          click_through: DotOne::Utils.to_percentage(stat[:clicks], stat[:impressions]),
          conversion_through: DotOne::Utils.to_percentage(stat[:captured], stat[:clicks]),
        }.merge(stat)
      end

      [sort_stats(stats), total_applied, total_active]
    end
  end

  def query_stats
    query_clicks.deep_merge(query_impressions)
  end

  def query_clicks
    affiliate_ids = affiliates.pluck(:id)

    Stat
      .stat([:affiliate_id], [:clicks, :captured], user_role: ability.user_role)
      .for_ad_links
      .between(*date_range, :recorded_at, time_zone)
      .each_with_object({}) do |stat, result|
        next if affiliate_ids.exclude?(stat.affiliate_id)

        result[stat.affiliate_id] = {
          clicks: stat.clicks.to_i,
          captured: stat.captured.to_i,
        }
      end
  end

  def query_impressions
    ::UniqueViewStat
      .select('affiliate_id, SUM(count) AS impressions')
      .with_affiliates(affiliates)
      .between(*date_range, :date, time_zone)
      .group(:affiliate_id)
      .each_with_object({}) do |stat, result|
        result[stat.affiliate_id] = { impressions: stat.impressions.to_i }
      end
  end

  def total_applied
    ::Affiliate.accessible_by(ability).where.not(ad_link_file: nil).count
  end

  def total_active
    ::UniqueViewStat
      .select('DISTINCT(affiliate_id)')
      .with_affiliates(affiliates)
      .where('date >= ?', 90.days.ago.utc.beginning_of_day)
      .count
  end

  def sort_stats(stats)
    if (field = params[:sort_field]&.to_sym) && (direction = params[:sort_order]&.to_sym)
      stats.sort_by { |a| a[field] * (direction == :asc ? 1 : -1) }
    else
      stats.sort_by { |a| -a[:impressions] }
    end
  end

  private

  def affiliates
    @affiliates ||= begin
      query = Affiliate.accessible_by(ability).with_affiliates(affiliate_ids)
      if date_range_applied.present?
        query = query.between(*date_range_applied, :ad_link_terms_accepted_at, time_zone)
      elsif date_range_activated.present?
        query = query.between(*date_range_activated, :ad_link_activated_at, time_zone)
      end

      query
    end
  end

  def cache_key_name(*keys)
    super([*keys, *params.values])
  end
end
