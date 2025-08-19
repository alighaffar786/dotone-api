class DotOne::Reports::Affiliates::ReferralEarnings < DotOne::Reports::ReferralEarnings
  DATE_RANGE_TYPES = [:this_month, :last_month, :lifetime]

  def total
    result = {
      approved_affiliate_pay: 0,
      referral_bonus: 0,
      count: 0,
    }

    referral_ids = query_referrals(end_date).pluck(:id)

    return result if referral_ids.blank?

    stat = query_total(start_date, end_date)

    return result unless stat

    result.merge(
      approved_affiliate_pay: stat.approved_affiliate_pay.to_f,
      referral_bonus: AffiliatePayment.calculate_earnings(stat.approved_affiliate_pay),
      count: query_stats(referral_ids).count(:affiliate_id).keys.size
    )
  end

  def summary
    DATE_RANGE_TYPES.each_with_object({}) do |date_range_type, result|
      date_range = time_zone.local_range(date_range_type)
      stat = query_total(*date_range)
      result[date_range_type] = AffiliatePayment.calculate_earnings(stat&.approved_affiliate_pay)
    end
  end

  def query_total(start_date, end_date)
    referral_ids = query_referrals(end_date).pluck(:id)

    return if referral_ids.blank?

    query = Stat
      .between(start_date, end_date, :converted_at, time_zone)
      .where(affiliate_id: referral_ids)
      .with_billing_regions(billing_region)
      .stat([], [:approved_affiliate_pay], currency_code: currency_code)
      .to_a
      .first
  end
end
