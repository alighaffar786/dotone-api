# frozen_string_literal: true

class Networks::MonthlyPerformanceReportEmailJob < NotificationJob
  def perform
    report_month = 1.month.ago.end_of_month
    Network.active.preload(:language).find_each(batch_size: 100) do |network|
      reports = DotOne::Reports::AdvertiserStats.new(network, report_month).build_report

      AdvertiserMailer.send_monthly_reports_email(network, reports, locale: network.locale, cc: true).deliver_later
    end
  end
end
