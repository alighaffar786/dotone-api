# frozen_string_literal: true

class MissingOrders::NotifyWaitingJob < NotificationJob
  def perform
    MissingOrder
      .confirming
      .confirming_n_days_ago(4)
      .find_each(batch_size: 100, &:notify_network)
  end
end
