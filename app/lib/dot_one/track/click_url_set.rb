class DotOne::Track::ClickUrlSet
  include ActiveModel::Model
  include DotOne::Utils::UrlHelpers

  OPTIONAL_FIELDS = [:subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :aff_uniq_id, :t]

  attr_accessor :affiliate_id, :affiliate_offer_id, :offer_variant_id,
    :subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :aff_uniq_id, :t, :for_social, :deeplink, :include_direct_url,
    :deeplink_urls

  attr_writer :affiliate, :affiliate_offer, :offer_variant

  validates :affiliate, :affiliate_offer, :offer_variant, presence: true

  def affiliate_offer
    @affiliate_offer ||= AffiliateOffer.cached_find(affiliate_offer_id)
  end

  def affiliate
    @affiliate ||= Affiliate.cached_find(affiliate_id) || affiliate_offer&.cached_affiliate
  end

  def offer_variant
    @offer_variant ||= OfferVariant.cached_find(offer_variant_id) || affiliate_offer&.default_offer_variant
  end

  def offer
    offer_variant.cached_offer
  end

  def deeplink_urls
    @deeplink_urls.reject(&:blank?)
  end

  def use_deeplink?
    deeplink && deeplink_urls.present?
  end

  def use_direct_network_url?
    offer.use_direct_advertiser_url? && offer.mkt_site.present?
  end

  def domain_for_social
    AlternativeDomain.temporary_tracking_domain_hosts.sample
  end

  def host
    if for_social && domain_for_social.present?
      domain_for_social
    else
      DotOne::Setup.dynamic_tracking_host(adult: offer.in_adult_category?)
    end
  end

  def token
    token_params = {
      affiliate_id: affiliate.id,
      affiliate_offer_id: affiliate_offer.id,
      offer_variant_id: offer_variant.id,
    }
    token_params[:tr] = affiliate_offer.token_refreshed_at if affiliate_offer.token_refreshed_at.present?

    DotOne::Track::Token.new(token_params)
  end

  def options
    OPTIONAL_FIELDS.each_with_object({}) do |key, result|
      if value = send(key).presence
        result[key] = value
      end
    end
  end

  def valid?
    super &&
      affiliate_offer.active? &&
      affiliate_offer.offer_id == offer_variant.offer_id
  end

  def generate
    return [] unless valid?
    return generate_deeplink_collection if use_deeplink?

    generate_basic_collection
  end

  private

  def generate_url(url_options = {})
    DotOne::Track::Routes.track_clicks_url(url_options.merge(
      id: offer_variant.id,
      token: token.encrypted_string,
      host: host,
    ))
  end

  def generate_direct_network_url(custom_url = nil, url_options = {})
    return unless use_direct_network_url?

    url = custom_url || offer_variant.destination_url
    click_stat = ClickStat.new(offer_id: offer.id, v2: true)
    token_formatter = DotOne::Track::TokenFormatter.new(url, click_stat)
    url = token_formatter.add_vtm_info(token: token)
    uri = parse(url)
    uri.query_values = (uri.query_values || {}).merge(url_options)
    uri.to_s
  end

  def generate_basic_collection
    result = []

    tracking_url = generate_url(options)
    result << {
      key: :tracking_url,
      url: tracking_url,
      short_url: shorten_url(tracking_url),
    }

    if direct_network_url = generate_direct_network_url(nil, options)
      result << {
        key: :direct_network_url,
        url: direct_network_url,
        short_url: shorten_url(direct_network_url),
      }
    end

    if include_direct_url
      direct_url = generate_url(t: t)
      result << {
        key: :direct_url,
        url: direct_url,
      }
    end

    result
  end

  def generate_deeplink_collection
    return unless use_deeplink?

    deeplink_modifier_original = offer.deeplink_modifier&.dig(:original)
    deeplink_modifier_replacement = offer.deeplink_modifier&.dig(:replacement)

    deeplink_urls.map do |url|
      unless is_valid_url?(url)
        raise DotOne::Errors::InvalidDataError.new(url, 'data.invalid_url', 'URL')
      end

      unless offer.destination_match?(url)
        raise DotOne::Errors::InvalidDataError.new(url, 'data.mismatch_with_merchant_url', 'URL')
      end

      url = url.gsub(deeplink_modifier_original.to_s, deeplink_modifier_replacement.to_s)
      url_options = options.merge(t: CGI.escape(CGI.unescape(url)))
      tracking_url = generate_url(url_options)

      result = {
        key: :deeplink_url,
        original_url: url,
        url: tracking_url,
        short_url: shorten_url(tracking_url),
      }

      if direct_network_url = generate_direct_network_url(url, url_options)
        result = result.merge(
          direct_network_url: direct_network_url,
          direct_network_short_url: shorten_url(direct_network_url),
        )
      end

      result
    rescue DotOne::Errors::BaseError => e
      {
        key: :deeplink_url,
        original_url: url,
        error: e.full_message,
      }
    end
  end
end
