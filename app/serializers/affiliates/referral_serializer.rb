class Affiliates::ReferralSerializer < ApplicationSerializer
  class AffiliateSerializer < Base::AffiliateSerializer
    attributes :id, :created_at, :referral_expired_at
  end

  has_one :affiliate, serializer: AffiliateSerializer

  attributes :affiliate_id, :approved_affiliate_pay, :referral_bonus

  def referral_bonus
    AffiliatePayment.calculate_earnings(object.approved_affiliate_pay)
  end
end
