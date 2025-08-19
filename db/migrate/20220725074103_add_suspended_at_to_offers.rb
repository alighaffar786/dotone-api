class AddSuspendedAtToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :suspended_at, :datetime
  end
end
