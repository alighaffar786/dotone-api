class DotOne::Constraints::ApiV2AffiliateConstraint < DotOne::Constraints::BaseConstraint
  def self.format_matched?(request)
    json_xml_format?(request)
  end

  def self.subdomain_matched?(request)
    [DotOne::Setup.affiliate_api_host, DotOne::Setup.api_host, 'affiliateone.online'].include?(request.host)
  end
end
