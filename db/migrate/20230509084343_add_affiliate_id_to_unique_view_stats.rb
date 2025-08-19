class AddAffiliateIdToUniqueViewStats < ActiveRecord::Migration[6.1]
  def change
    add_reference :unique_view_stats, :affiliate
  end
end
