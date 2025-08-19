class AddOrderTotalToStats < ActiveRecord::Migration[6.1]
  def change
    add_column :stats, :order_total, :decimal, precision: 20, scale: 2
  end
end
