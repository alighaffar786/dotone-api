# frozen_string_literal: true

class MissingOrders::NotifyAffiliateJob < NotificationJob
  delegate :affiliate, :status, to: :@missing_order

  def perform(id)
    @missing_order = MissingOrder.find(id)

    return if affiliate.blank?

    notify
  end

  def notify
    case status
    when MissingOrder.status_confirming
      AffiliateMailer.missing_order_confirming(affiliate, @missing_order, cc: true).deliver_later
    when MissingOrder.status_approved
      AffiliateMailer.missing_order_approved(affiliate, @missing_order, cc: true).deliver_later
    when MissingOrder.status_rejected, MissingOrder.status_rejected_by_admin, MissingOrder.status_rejected_by_advertiser
      AffiliateMailer.missing_order_rejected(affiliate, @missing_order, cc: true).deliver_later
    end
  end
end
