class Teams::ReferralSerializer < Base::AffiliateSerializer
  attributes :id, :created_at, :status, :referral_count, :approved_affiliate_pay, :referral_earnings, :referral_bonus

  def approved_affiliate_pay
    earnings[:approved_affiliate_pay].to_f
  end

  def referral_earnings
    earnings[:referral_earnings].to_f
  end

  def referral_bonus
    earnings[:referral_bonus].to_f
  end

  private

  def earnings
    instance_options.dig(:earnings, object.id) || {}
  end
end
