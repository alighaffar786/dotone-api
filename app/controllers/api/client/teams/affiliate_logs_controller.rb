class Api::Client::Teams::AffiliateLogsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def create
    @affiliate_log.agent = current_user

    if @affiliate_log.save
      respond_with @affiliate_log
    else
      respond_with @affiliate_log, status: :unprocessable_entity
    end
  end

  def sales_logs
    respond_with query_sales_logs, sales: true
  end

  private

  def query_sales_logs
    AffiliateLogCollection.new(current_ability, params, **current_options.merge(authorize: :sales_logs))
      .collect
      .sales_logs
      .preload(:agent, :owner)
  end

  def affiliate_log_params
    params.require(:affiliate_log).permit(
      :owner_id, :owner_type, :notes, :contact_target, :contact_media, :contact_stage, :sales_pipeline, :owner_grade,
      crm_infos_attributes: [:id, :crm_target_id, :crm_target_type, :contact_media, :_destroy]
    )
  end
end
