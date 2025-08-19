class Api::Client::Affiliates::Reports::StatsController < Api::Client::Affiliates::BaseController
  def performance_summary
    authorize! :read, Stat
    respond_with query_performance_summary
  end

  def confirmed_summary
    authorize! :read, Stat
    respond_with query_confirmed_summary
  end

  private

  def query_performance_summary
    fetch_cached([], 'StatPerformance', params[:start_date], params[:end_date], params[:billing_region], expires_in: 30.minutes) do
      report = DotOne::Reports::Affiliates::StatPerformance.new(current_ability, report_params)
      report.generate
    end
  end

  def query_confirmed_summary
    fetch_cached([], 'StatPerformance', params[:billing_region], :confirmed, expires_in: 30.minutes) do
      report = DotOne::Reports::Affiliates::StatPerformance.new(current_ability, report_params)
      report.generate_confirmed
    end
  end

  def report_params
    params.permit(:date_type, :billing_region, :start_date, :end_date).merge(current_options)
  end
end
