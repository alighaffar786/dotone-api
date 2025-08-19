module Track::ValidateHelper
  def check_on_click_geo_filter(inspect_info)
    return true unless current_offer
    return true unless current_offer.click_geo_filter
    return true unless allowed_country_codes = current_offer.cached_countries.map(&:iso_2_country_code).presence

    country_code = GEO_DB.lookup(request.remote_ip).country.iso_code

    if country_code.present? && allowed_country_codes.include?(country_code)
      return true
    else
      raise DotOne::Errors::ClickError::InvalidGeoError.new(params, inspect_info)
    end
  rescue
    raise DotOne::Errors::ClickError::InvalidGeoError.new(params, inspect_info)
  end

  def check_on_blacklisted_referer_domain(inspect_info)
    return true unless current_network
    return unless blacklisted_referer_domains = current_network.blacklisted_referer_domain_array.presence

    referer = request.referer
    matched = blacklisted_referer_domains.any? { |domain| referer.to_s.index(domain).present? }
    raise DotOne::Errors::ClickError::BlacklistedRefererDomainError.new(referer, params, inspect_info) if matched
  end

  def check_on_blacklisted_subids(inspect_info)
    return true unless current_network
    return unless blacklisted_subids = current_network.blacklisted_subids_array.presence

    current_subids.each do |key, value|
      next unless blacklisted_subids.include?(value)

      raise DotOne::Errors::ClickError::BlacklistedSubidError.new({ key => value }, params, inspect_info)
    end
  end

  def check_on_click_run(inspect_info)
    check_on_blacklisted_referer_domain(inspect_info)
    check_on_blacklisted_subids(inspect_info)
    check_on_click_geo_filter(inspect_info)
  end

  def is_s2s_blacklisted?
    BLACKLISTED_S2S.any? { |s| request.fullpath.include?(s) }
  end
end
