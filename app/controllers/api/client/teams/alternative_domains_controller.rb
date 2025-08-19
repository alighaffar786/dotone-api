class Api::Client::Teams::AlternativeDomainsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @alternative_domains = paginate(query_index)
    respond_with_pagination @alternative_domains, stats: query_stats
  end

  def create
    param = alternative_domain_params.merge(host_type: AlternativeDomain.host_type_tracking)

    @alternative_domains = AlternativeDomain.bulk_create(param)
    invalid = @alternative_domains.select(&:invalid?)
    @alternative_domains = @alternative_domains - invalid

    if @alternative_domains.present?
      respond_with @alternative_domains, each_serializer: Teams::AlternativeDomainSerializer
    else
      respond_with invalid.first, status: :unprocessable_entity
    end
  end

  def update
    if @alternative_domain.update(alternative_domain_params)
      respond_with @alternative_domain
    else
      respond_with @alternative_domain, status: :unprocessable_entity
    end
  end

  def destroy
    @alternative_domain.queue_destroy
    @alternative_domain.status = AlternativeDomain.status_deleted
    respond_with @alternative_domain
  end

  def bulk_deploy
    @alternative_domains = @alternative_domains.where(id: params[:ids])
    @alternative_domains.each(&:queue_deploy)
    respond_with @alternative_domains
  end

  private

  def query_index
    AlternativeDomainCollection.new(@alternative_domains, params).collect
  end

  def query_stats
    AlternativeDomainStat
      .select(:alternative_domain_id, :date, 'SUM(tracking_usage_count) AS tracking_usage_count', 'SUM(tracking_click_count) AS tracking_click_count')
      .between(*current_time_zone.local_range(:last_60_days), :date)
      .where(alternative_domain_id: @alternative_domains.map(&:id))
      .group(:date, :alternative_domain_id)
      .group_by(&:alternative_domain_id)
  end

  def alternative_domain_params
    params.require(:alternative_domain).permit(:host, :adult_only, :expired_at)
  end
end
