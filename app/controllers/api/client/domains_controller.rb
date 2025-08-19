class Api::Client::DomainsController < Api::Client::BaseController
  load_and_authorize_resource class: 'AlternativeDomain'

  def index
    respond_with @domains.success
  end
end
