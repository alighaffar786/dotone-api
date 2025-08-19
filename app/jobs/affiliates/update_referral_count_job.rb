# frozen_string_literal: true

class Affiliates::UpdateReferralCountJob < EntityManagementJob
  def perform(referrer_ids)
    Affiliate.where(id: referrer_ids).find_each do |affiliate|
      catch_exception do
        referral_count = affiliate.referrals.active_referrals(2.years.ago).count
        next if affiliate.referral_count == referral_count

        affiliate.update_columns(referral_count: referral_count, updated_at: Time.now)
      end
    end
  end
end
