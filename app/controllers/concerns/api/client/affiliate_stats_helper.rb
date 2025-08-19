module Api::Client::AffiliateStatsHelper
  include Api::Client::DownloadHelper

  private

  def build_stat_download(collection)
    build_download(collection, params[:columns], {
      include_conversion_data: data_type != :clicks,
    })
  end

  def query_countries(collection)
    Country
      .where(name: collection.map(&:ip_country).uniq)
      .index_by(&:name)
      .transform_keys(&:downcase)
  end

  def query_conversion_steps(collection)
    ConversionStep
      .preload_translations(:label)
      .where(name: collection.map(&:step_name), offer_id: collection.map(&:offer_id))
      .group_by(&:offer_id)
      .transform_values { |steps| steps.index_by(&:name) }
  end

  def query_conversion_counts(collection)
    counter = DotOne::Reports::ConversionCounter.new(collection)
    counter.generate
  end

  def query_approvals_from_orders(collection)
    orders = Order.valid_commissions.where(id: collection.map(&:order_id))
    AffiliateStat
      .select(:id, :approval)
      .where(id: orders.map(&:affiliate_stat_id))
      .where.not(approval: nil)
      .group_by(&:id)
      .transform_values { |values| values.map(&:approval).uniq }
  end

  def data_type
    (params[:data_type].presence || :clicks)&.to_sym
  rescue
    :clicks
  end

  def require_params
    return unless [:index, :download].include?(action_name.to_sym)
    return if params[:search_key].blank?

    extracted_search_params = Rails.cache.read(params[:search_key]) || {}
    params.merge!(extracted_search_params)
  end

  def search_params
    params.permit(:data_type, :field, :partial_by, search: [])
  end
end
