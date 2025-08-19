class DotOne::Constraints::ClientApiConstraint < DotOne::Constraints::BaseConstraint
  def self.format_matched?(request)
    json_format?(request)
  end

  def self.subdomain_matched?(request)
    request.host == DotOne::Setup.client_api_host
  end
end
