# frozen_string_literal: true

class Networks::SyncSalesPipelineJob < MaintenanceJob
  def perform
    Network.where(sales_pipeline: nil).where(status: [
      Network.status_new,
      Network.status_pending,
      Network.status_active,
      Network.status_suspended,
    ]).update_all(
      <<-SQL
        sales_pipeline = CASE
          WHEN status = '#{Network.status_new}' THEN '#{Network.sales_pipeline_new_lead}'
          WHEN status = '#{Network.status_pending}' THEN '#{Network.sales_pipeline_initial_contact}'
          WHEN status = '#{Network.status_active}' THEN '#{Network.sales_pipeline_deal_completed}'
          WHEN status = '#{Network.status_suspended}' THEN '#{Network.sales_pipeline_unqualified_lead}'
          ELSE NULL
        END
      SQL
    )
  end
end
