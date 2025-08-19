module DotOne::ApiClient::LineShared
  def request_uri
    return if @url_format.blank?
    return @request_uri if @request_uri.present?

    uri_string = @conversion_stat.format_pixel(@url_format)
    @request_uri = URI(uri_string) rescue nil
    @request_uri
  end

  def request_http
    return @http if @http.present?

    @http = nil
    uri = request_uri
    if uri.is_a?(URI::HTTPS)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      @http = Net::HTTP.new(uri.host, uri.port)
    end
    @http
  end

  def offer
    @conversion_stat&.cached_offer
  end

  def time_zone
    return @time_zone if @time_zone.present?

    @time_zone = @conversion_stat.cached_affiliate.time_zone
    @time_zone = TimeZone.default if @time_zone.blank?
    @time_zone
  end

  # Based on LINE requirements, order number
  # cannot contain certain characters
  def sanitize_order_number(order_number)
    return if order_number.blank?

    order_number.gsub('.', '-dot-').gsub(':', '-colon-')
  end
end
