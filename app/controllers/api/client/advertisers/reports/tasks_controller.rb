class Api::Client::Advertisers::Reports::TasksController < Api::Client::Advertisers::BaseController
  def index
    authorize! :read, current_user

    pending_conversions, start_date = count_pending_conversions

    result = fetch_cached_on_controller(expires_in: 30.minutes) do
      {
        pending_conversions: pending_conversions,
        confirming_missing_orders: count_confirming_missing_orders,
        start_date: start_date.to_date,
      }
    end

    respond_with result.compact
  end

  private

  def accessible_by(entity)
    entity.accessible_by(current_ability)
  end

  def count_pending_conversions
    start_date, end_date = current_time_zone.local_range(:last_6_months)

    count = accessible_by(AffiliateStatCapturedAt)
      .where(approval: AffiliateStat.approvals_considered_pending(:network))
      .between(start_date, end_date, :captured_at, current_time_zone).count


    [count, start_date]
  end

  def count_confirming_missing_orders
    accessible_by(MissingOrder).confirming.count
  end
end
