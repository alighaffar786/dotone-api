class DotOne::Track::Routes
  extend DotOne::Utils::UrlHelpers

  class << self
    def track_clicks_url(params = {})
      host =
        if params[:subid_1] == 'test'
          AlternativeDomain.tracking_domain_hosts.sample
        else
          params.delete(:host)
        end

      url_params = params.dup
      url_params.merge!(
        path: "track/clicks/#{url_params.delete(:id)}/#{url_params.delete(:token)}",
        host: host,
      )
      generate_tracking_url(url_params)
    end

    def track_impression_image_url(params = {})
      url_params = params.dup
      url_params.merge!(
        path: "track/imp/img/#{url_params.delete(:id)}/#{url_params.delete(:token)}",
      )
      generate_tracking_url(url_params)
    end

    def track_affiliate_referral_url(params = {})
      url_params = params.dup
      url_params.merge!(
        path: "track/affr/#{url_params.delete(:id)}",
      )
      generate_tracking_url(url_params)
    end

    def global_postback_url(params = {})
      url_params = params.dup
      url_params.merge!(
        path: "track/postback/conversions/#{DotOne::Setup.wl_id}/global"
      )
      generate_tracking_url(url_params, allow_blank: true)
    end

    protected

    def generate_tracking_url(params = {}, options = {})
      url_params = format_tracking_params(params, options)
      generate_url(url_params)
    end

    def format_tracking_params(params = {}, options = {})
      url_params = params.dup
      url_params = cleanup_params(url_params) unless options[:allow_blank].present?
      url_params.merge(
        scheme: params[:scheme] || DotOne::Setup.protocol,
        host: params[:host] || DotOne::Setup.tracking_host,
        query_values: url_params.except(:scheme, :host, :port, :path).presence,
      )
    end

    def cleanup_params(params)
      params.select { |_, v| v.present? }
    end
  end
end
