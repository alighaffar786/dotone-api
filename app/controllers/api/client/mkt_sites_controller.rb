class Api::Client::MktSitesController < Api::Client::BaseController
  load_resource

  def get_code
    authorize! :read, @mkt_site

    if @mkt_site.offer_id.present?
      respond_with @mkt_site, serializer: MktSite::CodeSerializer, for_gtm: for_gtm
    else
      head :not_found
    end
  end

  private

  def for_gtm
    truthy?(params[:for_gtm])
  end
end
