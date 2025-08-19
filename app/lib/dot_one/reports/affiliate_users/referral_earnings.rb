class DotOne::Reports::AffiliateUsers::ReferralEarnings < DotOne::Reports::ReferralEarnings
  attr_reader :affiliate_ids

  def initialize(user, options = {})
    super(user, options)
    @affiliate_ids = options[:affiliate_ids]
  end

  def referral_ids
    return [] if affiliate_ids.blank?
    @referral_ids ||= query_referrals(end_date).where(referrer_id: affiliate_ids).pluck(:id)
  end

  def referrer_referral_ids_map
    @referrer_referral_ids_map ||= Affiliate
      .where(id: referral_ids)
      .select(:referrer_id, :id)
      .group_by(&:referrer_id)
      .transform_values { |v| v.map(&:id) }
  end

  def generate
    all_affiliate_ids = affiliate_ids | referral_ids

    return {} if all_affiliate_ids.blank?

    stats = query_stats(all_affiliate_ids).index_by(&:affiliate_id)

    affiliate_ids.to_h do |affiliate_id|
      affiliate_referral_ids = referrer_referral_ids_map[affiliate_id] || []
      referral_earnings = affiliate_referral_ids.map { |referral_id| stats[referral_id]&.approved_affiliate_pay.to_f }.sum
      data = {
        approved_affiliate_pay: stats[affiliate_id]&.approved_affiliate_pay.to_f,
        referral_earnings: referral_earnings,
        referral_bonus: AffiliatePayment.calculate_earnings(referral_earnings),
      }

      [affiliate_id, data]
    end
  end
end
