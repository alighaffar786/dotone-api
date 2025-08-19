class DotOne::Constraints::ApiV2AdvertiserConstraint < DotOne::Constraints::BaseConstraint
  def self.format_matched?(request)
    json_xml_format?(request)
  end

  def self.subdomain_matched?(request)
    [DotOne::Setup.advertiser_api_host, DotOne::Setup.api_host].include?(request.host)
  end
end
