class Api::Client::Advertisers::SiteInfosController < Api::Client::Advertisers::BaseController
  load_resource

  def impressions
    authorize! :read_impression, @site_info
    respond_with @site_info.impressions
  end
end
