class DotOne::Constraints::BaseConstraint
  def self.matches?(request)
    result = format_matched?(request) && (dev?(request) || subdomain_matched?(request))
    Sentry.capture_exception(Exception.new("#{request.url} IP: #{request.ip}"), extra: { ip: request.ip }) unless result
    result
  end

  def self.dev?(request)
    # passing test_domain=1 param will force test domain mode in dev environment
    Rails.env.development? && request.params[:test_domain].blank?
  end

  def self.json_format?(request)
    request.format.to_s.match?(/json/)
  end

  def self.json_xml_format?(request)
    request.format.to_s.match?(/json|xml/)
  end
end
