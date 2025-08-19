class DotOne::Constraints::JsTrackingConstraint < DotOne::Constraints::BaseConstraint
  def self.matches?(request)
    result = dev?(request) || js_tracking_domain?(request)
    Sentry.capture_exception(Exception.new("#{request.url} IP: #{request.ip}"), extra: { ip: request.ip }) unless result
    result
  end

  def self.js_tracking_domain?(request)
    domain_matched = DotOne::Setup.js_tracking_host == request.domain
    path_matched = TRACK_JS_PATH_REGEX.match?(request.path)

    domain_matched && path_matched
  end
end
