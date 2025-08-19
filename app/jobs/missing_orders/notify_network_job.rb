# frozen_string_literal: true

class MissingOrders::NotifyNetworkJob < NotificationJob
  delegate :network, :confirming?, to: :@missing_order

  def perform(id)
    @missing_order = MissingOrder.find(id)

    notify if network.present? && confirming?
  end

  def notify
    AdvertiserMailer.missing_order_reminder(network, @missing_order, cc: true).deliver_later
  end
end
