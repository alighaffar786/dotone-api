class AddConfirmedAtToAffiliatePaymentInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_payment_infos, :confirmed_at, :datetime
  end
end
