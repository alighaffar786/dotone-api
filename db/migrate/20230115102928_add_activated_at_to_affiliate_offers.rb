class AddActivatedAtToAffiliateOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_offers, :activated_at, :datetime
  end
end
