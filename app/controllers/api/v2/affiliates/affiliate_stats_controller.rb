class Api::V2::Affiliates::AffiliateStatsController < Api::V2::Affiliates::BaseController
  before_action :validate_stat_start_date

  def conversions
    authorize! :read, AffiliateStat
    @affiliate_stats = paginate(query_conversions)
    respond_with_pagination @affiliate_stats, each_serializer: V2::Affiliates::AffiliateStatSerializer, root: :transactions
  end

  private

  def query_conversions
    AffiliateStatCollection.new(current_ability, conversions_params, **current_options)
      .collect
      .preload(copy_order: :affiliate_stat, offer: :name_translations)
  end

  def conversions_params
    params
      .permit(:time_zone, :subid_1s, :subid_2s, :subid_3s, :subid_4s, :subid_5s, :start_date, :end_date, :offer_ids)
      .merge(data_type: :captured, date_type: params[:date_type] || :captured_at).tap do |param|
        param[:start_date] ||= Date.today
        param[:end_date] ||= Date.today
      end
  end
end
