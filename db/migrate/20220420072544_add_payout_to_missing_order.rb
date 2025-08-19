class AddPayoutToMissingOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :missing_orders, :true_pay, :decimal, precision: 10, scale: 2
  end
end
