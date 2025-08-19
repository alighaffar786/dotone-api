class DotOne::Reports::ConversionAgings < DotOne::Reports::Base
  attr_accessor :ability, :offer_id, :time_zone, :age_first, :age_last

  def initialize(user, params = {})
    super(params)
    @ability = user.is_a?(Ability) ? user : Ability.new(user)
    @age_first = params[:age_first] || 0
    @age_last = params[:age_last] || 30
    @user_role = @ability.user_role
  end

  def generate
    Stat
      .accessible_by(ability)
      .stat([:offer_id], [:pending_conversions], user_role: @user_role)
      .pending_by_date_range(
        [
          :zero_to_thirty_days,
          :thirty_to_sixty_days,
          :sixty_to_one_eighty_days,
          :one_eighty_and_older_days,
        ],
        time_zone: time_zone,
        user_role: @user_role,
      )
      .order(pending_conversions: :desc)
  end

  def generate_by_offer(offer)
    now = time_zone.to_utc(time_zone.from_utc(Time.now).end_of_day).to_s(:db)
    date_range = time_zone.local_range(:x_to_y_days_ago, x: age_first, y: age_last)

    offer.offer_variants.flat_map do |offer_variant|
      offer.conversion_steps.map do |step|
        past_due_limit = step.days_to_return || 90

        data = Stat
          .accessible_by(ability)
          .select(
            <<-SQL.squish
              SUM(
                CASE
                  WHEN DATEDIFF(days, stats.captured_at, '#{now}') > #{past_due_limit}
                    AND approval IN ('#{AffiliateStat.approvals_considered_pending(@user_role).join("','")}')
                  THEN COALESCE(conversions, 0)
                  ELSE 0
                END
              ) AS past_due,
              SUM(
                CASE
                  WHEN DATEDIFF(days, stats.captured_at, '#{now}') <= #{past_due_limit}
                    AND approval IN ('#{AffiliateStat.approvals_considered_pending(@user_role).join("','")}')
                  THEN COALESCE(conversions, 0)
                  ELSE 0
                END
              ) AS current
            SQL
          )
          .where(step_name: step.name, offer_variant_id: offer_variant.id)
          .between(*date_range, :captured_at)[0]

        {
          id: [offer_variant.id, step.id].join('-'),
          offer: offer,
          offer_variant: offer_variant,
          step: step,
          past_due: data.past_due.to_i,
          current: data.current.to_i,
          start_date: date_range.first.strftime('%Y-%m-%d'),
          end_date: date_range.last.strftime('%Y-%m-%d'),
        }
      end
    end
  end
end
