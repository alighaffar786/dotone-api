class AffiliateStats::OrderApiHandlerJob < EntityManagementJob
  def perform(**params)
    params[:network] = Network.cached_find(params.delete(:network_id)) if params[:network_id].present?

    handler = DotOne::AffiliateStats::OrderApiHandler.new(**params)

    if handler.valid?
      handler.save
    elsif handler.delay? && params[:order].present? && params[:server_subid].present? && AffiliateStat.valid_id?(params[:server_subid])
      raise ActiveRecord::RecordNotFound, handler.errors.full_messages.join(', ')
    end
  end
end
