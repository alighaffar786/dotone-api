module DotOne::Utils
  module UrlHelpers
    def generate_url(params = {})
      uri = Addressable::URI.new(params)
      uri.to_s
    end

    def shorten_url(url)
      TinyurlShortener.shorten(url).to_s
    rescue StandardError
      url
    end

    def parse(url, flexible: false)
      url = url.to_s.strip
      uri = Addressable::URI.parse(url)
      uri = Addressable::URI.parse("https://#{url}") if flexible && uri.host.blank?
      return unless PublicSuffix.valid?(uri.host, default_rule: nil)

      uri
    rescue Addressable::URI::InvalidURIError
    end

    def flexible_parse(url)
      parse(url, flexible: true)
    end

    def host_name(url)
      uri = flexible_parse(url)
      uri&.host
    end

    def is_valid_url?(url)
      if uri = parse(url)
        ['http', 'https'].include?(uri.scheme)
      else
        false
      end
    end

    def host_name_without_www(url)
      host = host_name(url).to_s
      host.gsub!('www.', '') if host.start_with?('www.')
      host.presence
    end

    def domain_name_without_tld(url)
      return unless uri = flexible_parse(url)

      uri.domain.gsub(".#{uri.tld}", '')
    end

    def domain_name(url)
      uri = flexible_parse(url)
      uri&.domain
    end

    def host_match?(url_1, url_2)
      return false unless host_1 = host_name(url_1)
      return false unless host_2 = host_name(url_2)

      host_1 == host_2
    end

    def domain_match?(url_1, url_2)
      return false unless domain_1 = domain_name(url_1)
      return false unless domain_2 = domain_name(url_2)

      domain_1 == domain_2
    end
  end
end
