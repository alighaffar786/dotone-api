# frozen_string_literal: true

class MissingOrders::AutoApproveWaitingJob < MaintenanceJob
  def perform
    MissingOrder
      .confirming
      .confirming_n_days_ago_or_older(7)
      .find_each(batch_size: 100) do |missing_order|
        catch_exception { missing_order.auto_approve! }
      end
  end
end
