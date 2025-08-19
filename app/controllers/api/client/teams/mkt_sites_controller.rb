class Api::Client::Teams::MktSitesController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    @mkt_sites = paginate(query_index)
    respond_with_pagination @mkt_sites
  end

  def create
    if @mkt_site.save
      respond_with @mkt_site
    else
      respond_with @mkt_site, status: :unprocessable_entity
    end
  end

  def update
    if @mkt_site.update(mkt_site_params)
      respond_with @mkt_site
    else
      respond_with @mkt_site, status: :unprocessable_entity
    end
  end

  def destroy
    if @mkt_site.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def search
    authorize! :read, MktSite
    respond_with query_search, each_serializer: Teams::MktSite::SearchSerializer
  end

  private

  def query_index
    MktSiteCollection.new(current_ability, params)
      .collect
      .preload(
        :network,
        offer: [:name_translations, :js_conversion_pixel],
        affiliate: :affiliate_application,
      )
  end

  def mkt_site_params
    params
      .require(:mkt_site)
      .permit(:offer_id, :affiliate_id, :network_id, :domain, :verified, :platform, accepted_origins: [])
  end

  def query_search
    MktSiteCollection.new(current_ability, params).collect
  end
end
