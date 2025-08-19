class Api::Client::Teams::Reports::ReferralsController < Api::Client::Teams::BaseController
  def index
    authorize! :read, Affiliate
    @affiliates = paginate(query_affiliates)
    respond_with_pagination @affiliates, each_serializer: Teams::ReferralSerializer, earnings: query_earnings
  end

  def details
    @affiliate = Affiliate.find(params[:affiliate_id])
    authorize! :read, @affiliate
    @referrals = paginate(query_details)
    respond_with_pagination @referrals.preload(affiliate: :affiliate_application), each_serializer: Teams::Referral::DetailsSerializer
  end

  private

  def query_affiliates
    collection = AffiliateCollection.new(current_ability, params.slice(:ids)).collect
    collection.with_referrals.preload(:affiliate_application)
  end

  def query_earnings
    report = DotOne::Reports::AffiliateUsers::ReferralEarnings.new(current_ability, referrals_params.merge(affiliate_ids: @affiliates.map(&:id)))
    report.generate
  end

  def query_details
    report = DotOne::Reports::Affiliates::ReferralEarnings.new(@affiliate, referrals_params)
    report.query_stats
  end

  def referrals_params
    params
      .permit(:start_date, :end_date, :billing_region, :date_range_type, :referral_type)
      .merge(currency_code: current_currency_code, time_zone: current_time_zone)
  end
end
