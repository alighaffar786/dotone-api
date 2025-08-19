class Api::Client::Teams::AffiliateProspectsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @affiliate_prospects = paginate(query_index)
    respond_with_pagination @affiliate_prospects
  end

  def create
    @affiliate_prospect.recruiter = current_user
    @affiliate_prospect.valid?
    if @affiliate_prospect.save
      respond_with @affiliate_prospect
    else
      respond_with @affiliate_prospect, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_prospect.update(affiliate_prospect_params)
      respond_with @affiliate_prospect
    else
      respond_with @affiliate_prospect, status: :unprocessable_entity
    end
  end

  def destroy
    if @affiliate_prospect.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    AffiliateProspectCollection.new(current_ability, params)
      .collect
      .preload(
        :country, :affiliate_prospect_categories, :recruiter,
        affiliate: :affiliate_application,
        site_info: :media_category,
        categories: :category_group,
        affiliate_logs: [:agent, :crm_info, :crm_infos]
      )
  end

  def affiliate_prospect_params
    params.require(:affiliate_prospect).permit(
      :email, :country_id, category_ids: [],
      site_info_attributes: [:id, :username, :url, :followers_count, :media_category_id, appearances: []]
    )
  end
end
