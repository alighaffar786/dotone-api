class Api::Client::Affiliates::SiteInfosController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: :create
  load_and_authorize_resource through: :current_user, on: :create

  def index
    respond_with @site_infos.preload(:categories, media_category: :parent_category)
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

  def site_info_params
    params.require(:site_info).permit(
      :access_token, :url, :description, :comments, :unique_visit_per_day, :brand_domain_opt_outs, :page_url_opt_outs,
      :media_count, :account_id, :account_type, :username, :last_media_posted_at, :followers_count, :unique_visit_per_month,
      :refresh_token, :media_category_id, :ad_link_enabled, :verifiable, category_ids: [], brand_domain_opt_outs: [], page_url_opt_outs: []
    )
  end
end
