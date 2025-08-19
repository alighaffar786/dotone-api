class AddContactToAffiliateLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_logs, :contact_target, :string
    add_column :affiliate_logs, :contact_media, :string
    add_column :affiliate_logs, :contact_stage, :string
    add_column :affiliate_logs, :sales_pipeline, :string
  end
end
