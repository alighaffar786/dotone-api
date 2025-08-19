# frozen_string_literal: true

class AffiliateUsers::ClaimableAffiliateBalanceJob < NotificationJob
  def perform
    email_template = EmailTemplate.find_by_email_type(EmailTemplate::EMAIL_TYPE_CLAIMABLE_BALANCE_REPORT)
    return if email_template.blank?

    report_paths = DotOne::Reports::AffiliateUsers::ClaimableAffiliateBalance.new.generate

    opt_in_users = email_template.email_opt_ins.map(&:owner)

    opt_in_users.each do |user|
      next unless user.respond_to?(:active?) && user.active?

      ClaimableAffiliateBalanceMailer.send_report(user, report_paths, email_template).deliver_later
    end
  end
end
