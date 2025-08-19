class Api::Client::Affiliates::Reports::ReferralsController < Api::Client::Affiliates::BaseController
  def index
    authorize! :refer, Affiliate
    @referrals = paginate(query_index)
    respond_with_pagination @referrals, each_serializer: Affiliates::ReferralSerializer, meta: { total: query_total }
  end

  def summary
    authorize! :refer, Affiliate
    respond_with query_summary
  end

  private

  def query_index
    report = DotOne::Reports::Affiliates::ReferralEarnings.new(current_ability, report_params)
    report.query_stats
  end

  def query_total
    report = DotOne::Reports::Affiliates::ReferralEarnings.new(current_ability, report_params)
    report.total
  end

  def query_summary
    report = DotOne::Reports::Affiliates::ReferralEarnings.new(current_ability, report_params.merge(referral_type: :active))
    report.summary
  end

  def report_params
    params
      .permit(:start_date, :end_date, :billing_region, :date_range_type, :referral_type)
      .merge(currency_code: current_currency_code, time_zone: current_time_zone)
  end
end
