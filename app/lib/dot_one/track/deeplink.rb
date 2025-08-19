require 'addressable/uri'

class DotOne::Track::Deeplink
  ##
  # Method to add additional deeplink parameters to the target URL
  # Several conditions before we add the additional parameters are:
  #   - The URL needs to come from URL chosen by the Affiliates. (reside in params[:t])
  #   - The default offer variant is set to configurable by Affiliates.
  # == Use case:
  # Deeplink parameter needs to be added to direct deeplinking URL.
  # Sometimes, direct advertisers need to know where the traffic coming
  # from by using utm_source=, or any other parameters.

  def self.add_parameters(url, offer_variant, click_stat)
    return if url.blank?
    return url if click_stat.blank? && offer_variant.blank?

    # Some offers have specific parameters to add for
    # each deeplinking URL. Let's add them here
    additional_parameter_queries = {}

    offer = offer_variant&.cached_offer

    if offer
      default_variant = offer.cached_default_offer_variant

      return url unless default_variant&.can_config_url?

      current_stat = click_stat.to_stat

      additional_parameters = default_variant.deeplink_parameters || []
      additional_parameters.each do |pair|
        additional_parameter_queries[pair['key']] = current_stat.format_content(pair['value'], :url)
      end
    end

    if offer&.do_not_reformat_deeplink_url?
      # System will simply append additional parameters
      # to the end of supplied url for any URL that is considered
      # not in standardized format

      # To record all keys that have been replaced in the URL
      used_keys = []

      # Replace any existing parameters with the ones
      # that we have - manually
      additional_parameter_queries.each_pair do |key, value|
        new_url = url.split("#{key}=")
        if new_url[1]
          qs_segments = new_url[1].split('&')
          qs_segments.shift
          url = [new_url[0], "#{key}=#{value}&", qs_segments.join('&')].join
          used_keys << key
        else
          url = new_url[0]
        end
      end

      uri = Addressable::URI.new

      uri.query_values = additional_parameter_queries.delete_if do |key, _value|
        used_keys.include?(key)
      end

      # Handle basic manual format as needed
      if !url.include?('?') && !url.include?('&')
        [url, '?', uri.query].join
      elsif url.include?('&') || url.include?('?')
        [url, '&', uri.query].join
      else
        [url, uri.query].join
      end
    else
      # System will try to parse and reformat the query
      # strings when adding additional parameters
      uri = DotOne::Utils::Url.flexible_parse(url)

      if uri && additional_parameter_queries.present?
        uri.query_values = (uri.query_values || {}).merge(additional_parameter_queries)
      end
      # Regenerate the new deeplink URL here
      uri.to_s.gsub(TOKEN_TID, click_stat.id).presence
    end
  end

  def self.contain_deeplink_token?(url)
    url.present? &&
      (url.index(TOKEN_DEEPLINKING).present? ||
       url.index(TOKEN_DEEPLINKING_DECODED).present? ||
       url.index(TOKEN_DEEPLINKING_DOUBLE_ENCODED).present?)
  end

  ##
  # Need to check whether URL from stat (offer destination URL) contains
  # deeplinking token. If so, destination URL is chosen first
  def self.choose_redirection(custom_url, click_stat_url)
    return click_stat_url if DotOne::Track::Deeplink.contain_deeplink_token?(click_stat_url)
    return custom_url if custom_url.present?

    click_stat_url
  end

  def self.extract_host_name(url, v2: true)
    parser = v2 ? CGI : URI::DEFAULT_PARSER

    url = parser.unescape(url.to_s)
    first_host_name = DotOne::Utils::Url.host_name_without_www(url)

    return first_host_name if first_host_name.present?

    url = parser.escape(parser.unescape(url.to_s))
    second_host_name = DotOne::Utils::Url.host_name_without_www(url)

    second_host_name
  end

  def self.extract_domain(url, v2: true)
    parser = v2 ? CGI : URI::DEFAULT_PARSER

    url = parser.unescape(url.to_s)
    first_domain_name = DotOne::Utils::Url.domain_name(url)

    return first_domain_name if first_domain_name.present?

    url = parser.escape(parser.unescape(url.to_s))
    second_domain_name = DotOne::Utils::Url.domain_name(url)

    second_domain_name
  end

  def self.host_in_whitelisted?(offer_variant, target_url, v2: true)
    urls = offer_variant.destination_urls
    contains_comma = target_url.include?(',') && offer_variant.cached_offer.id == 6434

    if offer_variant.cached_offer.whitelisted? && !contains_comma
      hosts = urls.map { |url| extract_host_name(url, v2: v2) }.reject(&:blank?).uniq

      return [false, target_url] if hosts.blank?

      target_host = extract_host_name(target_url, v2: v2)
      return [false, target_url] if target_host.blank?

      result = hosts.any? { |host| host == target_host }

      unless result
        to_ignore = ['coupang.com']

        unless to_ignore.any? { |x| DotOne::Utils::Url.domain_name(target_host)&.include?(x) }
          partial = hosts.any? { |host| DotOne::Utils::Url.domain_match?(host, target_host) }
          Sentry.capture_exception(Exception.new("WHITELIST ALERT: #{target_url}")) if partial
        end
      end

      [result, target_url]
    else
      domains = urls.map { |url| extract_domain(url, v2: v2) }.reject(&:blank?).uniq

      return [false, target_url] if domains.blank?

      target_domain = extract_domain(target_url, v2: v2)
      return [false, target_url] if target_domain.blank?

      result = domains.any? { |domain| domain == target_domain }

      if result && contains_comma
        [result, offer_variant.destination_url]
      else
        [result, target_url]
      end
    end
  end

  def self.parse_t_params(url, v2: true)
    2.times do
      if v2
        url = CGI.unescape(url)
      else
        url = URI::DEFAULT_PARSER.unescape(url)
      end

      url = DotOne::Utils.to_utf8(url)
    end

    url
  end
end
