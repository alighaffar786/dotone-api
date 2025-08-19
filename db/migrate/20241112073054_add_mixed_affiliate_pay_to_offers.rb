class AddMixedAffiliatePayToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :mixed_affiliate_pay, :boolean, default: false
  end
end
