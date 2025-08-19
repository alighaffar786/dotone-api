class Api::Client::Advertisers::AffiliatesController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource except: [:recent, :search]

  def index
    @affiliates = paginate(query_index)
    respond_with_pagination @affiliates
  end

  def update
    if @affiliate.update(affiliate_params)
      respond_with @affiliate
    else
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def recent
    authorize! :read, Affiliate
    respond_with query_recent, affiliate_conversion_count: affiliate_conversion_count
  end

  def search
    authorize! :read, Affiliate
    respond_with query_search, each_serializer: Advertisers::Affiliate::SearchSerializer
  end

  private

  def query_index
    AffiliateCollection.new(current_ability, params)
      .collect
      .select_joined_at(current_user.id)
      .reorder(last_joined_at: :desc)
      .preload(*preload_associations)
  end

  def query_recent_ids
    AffiliateCollection.new(current_ability)
      .collect
      .select_joined_at(current_user.id)
      .where('first_joined_at >= ?', 60.days.ago)
      .pluck(:id)
  end

  def query_recent
    AffiliateCollection.new(current_ability)
      .collect
      .where(id: affiliate_conversion_count.keys)
      .reorder(Arel.sql("FIELD(affiliates.id, #{affiliate_conversion_count.keys.join(',')})"))
      .preload(*preload_associations)
  end

  def query_search
    AffiliateCollection.new(current_ability, params).collect
  end

  def affiliate_conversion_count
    @affiliate_conversion_count ||= begin
      report = DotOne::Reports::AffiliateConversionCount.new(
        current_ability,
        affiliate_ids: query_recent_ids,
        time_zone: current_time_zone,
      )
      report.generate.take(5).to_h
    end
  end

  def preload_associations
    [
      :avatar, :affiliate_application, :aff_hash,
      network_logs: [:agent], site_infos: [:categories, media_category: :parent_category]
    ]
  end

  def affiliate_params
    params.require(:affiliate).permit(:status, :label).tap do |param|
      param.delete(:status) unless accepted_statuses.include?(param[:status]) && params[:status] != @affiliate.status
    end
  end

  def accepted_statuses
    [
      Affiliate.status_active,
      Affiliate.status_paused,
      Affiliate.status_suspended,
    ]
  end
end
