class AddFlexibleAffiliatePayToConversionSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :conversion_steps, :affiliate_pay_flexible, :boolean, default: false
    add_column :conversion_steps, :max_affiliate_pay, :decimal, precision: 20, scale: 2
  end
end
