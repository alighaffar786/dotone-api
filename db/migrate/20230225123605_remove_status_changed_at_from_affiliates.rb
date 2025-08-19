class RemoveStatusChangedAtFromAffiliates < ActiveRecord::Migration[6.1]
  def up
    remove_column :affiliates, :status_changed_at
  end

  def down
    add_column :affiliates, :status_changed_at, :datetime
  end
end
