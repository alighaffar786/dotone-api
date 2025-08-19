# frozen_string_literal: true

class AffiliateUsers::WeeklyPerformanceReportEmailJob < NotificationJob
  def perform
    email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_WEEKLY_PERFORMANCE_REPORT)
    return if email_template.blank?

    today = DateTime.now.getlocal(TimeZone.platform.gmt_string)
    xls = DotOne::Reports::AffiliateUsers::WeeklyPerformance.new(today).build_report
    xls_content = File.read(xls)

    opt_in_users = email_template.email_opt_ins.map(&:owner)

    catch_exception do
      opt_in_users.each do |user|
        if user.respond_to?(:active?) && user.active?
          WeeklyPerformanceMailer.send_report(user, xls_content, email_template).deliver_now
        end
      end
    end

    File.delete(xls)
  end
end
