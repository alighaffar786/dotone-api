class DotOne::Reports::ReferralEarnings < DotOne::Reports::Base
  attr_reader :referral_type, :start_date, :end_date, :ability, :user_role, :billing_region

  def initialize(user, options = {})
    super(options)
    @ability = user.is_a?(Ability) ? user : Ability.new(user)

    @start_date, @end_date = time_zone.local_range(options[:date_range_type]) if options[:date_range_type].present?
    @start_date ||= options[:start_date]
    @end_date ||= options[:end_date]
    @start_date, @end_date = time_zone.local_range(:this_month) if @start_date.blank? || @end_date.blank?

    @referral_type = options[:referral_type]&.to_sym || :active
    @billing_region = options[:billing_region]
    @user_role = @ability.user_role
  end

  def query_stats(given_referral_ids = nil)
    referral_ids = given_referral_ids || query_referrals(end_date).pluck(:id)

    return Stat.none if referral_ids.blank?

    query = Stat
      .between(start_date, end_date, :converted_at, time_zone)
      .where(affiliate_id: referral_ids)
      .with_billing_regions(billing_region)
      .stat([:affiliate_id], [:approved_affiliate_pay], currency_code: currency_code, user_role: :affiliate)
  end

  def query_referrals(referral_expired_at)
    case user_role
    when :owner
      Affiliate.accessible_by(ability).active_referrals(referral_expired_at, time_zone)
    when :affiliate
      Affiliate.accessible_by(ability, :refer).referrals_by_expiration_type(referral_type, referral_expired_at, time_zone)
    else
      Affiliate.none
    end
  end
end
