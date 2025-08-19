class AddStartDateAndEndDateToAffiliatePayments < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_payments, :start_date, :date
    add_column :affiliate_payments, :end_date, :date
    add_column :affiliate_payments, :paid_date, :date
  end
end
