# frozen_string_literal: true

class Api::Client::Advertisers::DashboardsController < Api::Client::Advertisers::BaseController
  DotOne::Reports::NetworkDashboard.report_types.each do |report_type|
    define_method(report_type) do
      authorize! :read, Stat
      report_klass = "DotOne::Reports::Dashboard::#{report_type.to_s.classify}".constantize
      @report = report_klass.new(report_params)
      respond_with @report.generate
    end
  end

  def index
    authorize! :read, Stat
    @report = DotOne::Reports::NetworkDashboard.new(report_params)
    respond_with @report.generate
  end

  private

  def meta_options
    return super unless @report.try(:pagination)

    super.deep_merge(meta: { pagination: @report.pagination })
  end

  def report_params
    {
      network: current_user,
      time_zone: current_time_zone,
      currency_code: current_currency_code,
      params: params,
    }
  end

  def require_params
    case action_name.to_sym
    when :performance_stat
      params.require(:duration)
    else
      super
    end
  end
end
