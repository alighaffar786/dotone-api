class AddSalesPipelineToNetworks < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :sales_pipeline, :string

    Network.where(status: Network.status_new).update_all(sales_pipeline: Network.sales_pipeline_new_lead)
    Network.where(status: Network.status_new).where.not(recruiter_id: nil).update_all(sales_pipeline: Network.sales_pipeline_qualified_lead)
    Network.pending.update_all(sales_pipeline: Network.sales_pipeline_initial_contact)
    Network.suspended.update_all(sales_pipeline: Network.sales_pipeline_unqualified_lead)
    Network.active.update_all(sales_pipeline: Network.sales_pipeline_deal_completed)
    Network.paused.update_all(sales_pipeline: Network.sales_pipeline_deal_completed)
  end
end
