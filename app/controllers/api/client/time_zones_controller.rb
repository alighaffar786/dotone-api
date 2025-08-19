class Api::Client::TimeZonesController < Api::Client::BaseController
  load_and_authorize_resource

  def index
    data = fetch_global_cached_on_controller { @time_zones.to_a }
    respond_with data, each_serializer: TimeZoneSerializer
  end
end
