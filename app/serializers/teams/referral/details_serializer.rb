class Teams::Referral::DetailsSerializer < Affiliates::ReferralSerializer
  class AffiliateSerializer < Base::AffiliateSerializer
    attributes :id, :created_at, :referral_expired_at
  end

  has_one :affiliate, serializer: AffiliateSerializer

  attributes :affiliate_id, :approved_affiliate_pay, :referral_bonus, :referrer_id

  def referral_bonus
    AffiliatePayment.calculate_earnings(object.approved_affiliate_pay)
  end

  def referrer_id
    object.affiliate.referrer_id
  end
end
