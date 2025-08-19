class Api::Client::Teams::Reports::AffiliateLogsController < Api::Client::Teams::BaseController
  def sales_summary
    authorize! :sales_summary, AffiliateLog
    respond_with query_sales_summary, each_serializer: Teams::AffiliateLog::SalesSummarySerializer
  end

  private

  def query_sales_summary
    AffiliateLog.sales_summary(params.merge(agent_ids: AffiliateUser.sales_team.active, time_zone: current_time_zone))
  end
end
