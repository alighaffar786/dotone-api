class AddTaxRegionToAffiliatePayments < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_payments, :tax_region, :string
  end
end
