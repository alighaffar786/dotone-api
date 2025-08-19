class DotOne::Constraints::TrackingConstraint < DotOne::Constraints::BaseConstraint
  def self.matches?(request)
    result = dev?(request) || tracking_domain?(request) || conversion_domain?(request)
    Sentry.capture_exception(Exception.new("#{request.url} IP: #{request.ip}"), extra: { ip: request.ip }) unless result
    result
  end

  def self.tracking_domain?(request)
    domain_matched = DotOne::Cache.domain(request.domain)

    domain_matched && !conversion_path?(request.path)
  end

  def self.conversion_domain?(request)
    conversion_path?(request.path) && (AlternativeDomain.conversion_domain?(request.domain) || request.params[:test].present?)
  end

  def self.conversion_path?(path)
    TRACK_CONVERSION_PATH_REGEX.match?(path)
  end
end
