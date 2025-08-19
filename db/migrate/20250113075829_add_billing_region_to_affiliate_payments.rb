class AddBillingRegionToAffiliatePayments < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_payments, :billing_region, :string
  end
end
