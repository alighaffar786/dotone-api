class DotOne::Reports::AffiliateConversionCount < DotOne::Reports::Base
  attr_accessor :ability, :affiliate_ids, :date_range

  def initialize(user, params = {})
    super(params)
    @ability = user.is_a?(Ability) ? user : Ability.new(user)
    @affiliate_ids = params[:affiliate_ids].to_a
    @date_range = @time_zone.local_range(:x_to_y_days_ago, x: 0, y: 60)
  end

  def generate
    super do
      stats.to_h do |stat|
        affiliate_ids.delete(stat.affiliate_id)
        [stat.affiliate_id, { clicks: stat.clicks, captured: stat.captured }]
      end.tap do |hash|
        # set default value when affiliate ids not exist in stats
        affiliate_ids.each { |id| hash[id] = { clicks: 0, captured: 0 } }
      end
    end
  end

  private

  def stats
    Stat
      .accessible_by(ability)
      .stat([:affiliate_id], [:clicks, :captured], user_role: :network)
      .where(affiliate_id: affiliate_ids)
      .between(*date_range, :recorded_at, time_zone)
      .order('captured desc, clicks desc')
  end

  def cache_key_name
    super(affiliate_ids)
  end
end
