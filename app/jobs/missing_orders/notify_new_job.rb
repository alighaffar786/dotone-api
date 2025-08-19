# frozen_string_literal: true

class MissingOrders::NotifyNewJob < NotificationJob
  def perform
    date = Date.today
    missing_orders = MissingOrder
      .joins(:affiliate_users)
      .where(created_at: (date.beginning_of_day...date.end_of_day))
      .group('affiliate_users.id')
      .count

    missing_orders.each do |affiliate_user_id, count|
      next if count == 0

      affiliate_user = AffiliateUser.find(affiliate_user_id)
      AffiliateUserMailer.new_missing_orders(affiliate_user, date, count).deliver_later
    end
  end
end
