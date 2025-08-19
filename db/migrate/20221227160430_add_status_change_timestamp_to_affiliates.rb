class AddStatusChangeTimestampToAffiliates < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :activated_at, :datetime
    add_column :affiliates, :suspended_at, :datetime
    add_column :affiliates, :paused_at, :datetime
  end
end
