class Api::Client::Teams::SiteInfosController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index
  end

  def show
    respond_with @site_info
  end

  def create
    if @site_info.save
      respond_with @site_info
    else
      respond_with @site_info, status: :unprocessable_entity
    end
  end

  def update
    if @site_info.update(site_info_params)
      respond_with @site_info
    else
      respond_with @site_info, status: :unprocessable_entity
    end
  end

  def destroy
    if @site_info.destroy_if_applicable!
      head :ok
    else
      respond_with @site_info, status: :unprocessable_entity
    end
  end

  private

  def require_params
    params.require(:affiliate_id) if action_name.to_sym == :index
  end

  def query_index
    @site_infos
      .joins(:affiliate)
      .with_affiliates(params[:affiliate_id])
      .preload(:categories, media_category: :parent_category)
  end

  def site_info_params
    params.require(:site_info).permit(
      :url, :description, :comments, :unique_visit_per_day, :affiliate_id, :media_category_id, :ad_link_enabled, :verifiable,
      :followers_count, category_ids: []
    )
  end
end
