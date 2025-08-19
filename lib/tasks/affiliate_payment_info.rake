namespace :wl do
  namespace :affiliate_payment_infos do
    task set_confirmed_at: :environment do
      AffiliatePaymentInfo.confirmed.find_each do |info|
        info.update_attribute(:confirmed_at, info.updated_at)
      end
    end
  end
end
