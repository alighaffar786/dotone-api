class AddStatusChangedAtToAffiliates < ActiveRecord::Migration[6.1]
  def up
    add_column :affiliates, :status_changed_at, :datetime

    Affiliate.find_each do |affiliate|
      status_changed_at = affiliate.activated_at if affiliate.active?
      status_changed_at = affiliate.paused_at if affiliate.paused?
      status_changed_at = affiliate.suspended_at if affiliate.suspended?
      status_changed_at ||= affiliate.updated_at

      affiliate.update_column(:status_changed_at, status_changed_at)
    end

    remove_column :affiliates, :activated_at
    remove_column :affiliates, :paused_at
    remove_column :affiliates, :suspended_at
  end

  def down
    remove_column :affiliates, :status_changed_at
    add_column :affiliates, :activated_at, :datetime
    add_column :affiliates, :paused_at, :datetime
    add_column :affiliates, :suspended_at, :datetime
  end
end
