class DotOne::Setup
  HOSTS = {
    cdn: ENV.fetch('CDN_HOST'),
    ad_link: ENV.fetch('AD_LINK_HOST'),
    affiliate: [ENV.fetch('AFFILIATE_UI_HOST'), 'affiliates'],
    advertiser: [ENV.fetch('ADVERTISER_UI_HOST'), 'advertisers'],
    admin: [ENV.fetch('ADMIN_UI_HOST'), 'teams'],
    tracking: ENV.fetch('TRACKING_HOST'),
    js_tracking: ENV.fetch('JS_TRACKING_HOST'),
    client_api: ENV.fetch('CLIENT_API_HOST'),
    advertiser_api: ENV.fetch('ADVERTISER_API_HOST'),
    affiliate_api: ENV.fetch('AFFILIATE_API_HOST'),
    api: ENV.fetch('API_HOST'),
  }

  class << self
    HOSTS.each do |name, value|
      values = [value].flatten

      define_method "#{name}_host" do
        values.first
      end

      define_method "#{name}_url" do |locale = nil, skip_locale = false|
        url = if [:affiliate, :advertiser, :admin].include?(name)
          [values[0], skip_locale ? nil : (locale || Language.current_locale), *values[1..-1]].compact.join('/')
        else
          values.join('/')
        end

        attach_protocol(url)
      end
    end

    def wl_company
      WlCompany.default
    end

    def wl_id
      Rails.env.production? ? 8 : 1
    end

    def wl_name
      wl_company.name
    end

    def general_contact_email
      wl_company.general_contact_email
    end

    def affiliate_contact_email
      wl_company.affiliate_contact_email
    end

    def wl_setup(key)
      wl_company.setup[key]
    end

    def platform_language
      Language.cached_find_by(code: ENV.fetch('LANGUAGE_CODE'))
    end

    def platform_currency
      Currency.cached_find_by(code: ENV.fetch('CURRENCY_CODE'))
    end

    def platform_time_zone
      TimeZone.cached_find_by(gmt: ENV.fetch('TIMEZONE_GMT'))
    end

    def protocol
      Rails.env.production? ? 'https' : wl_company.panel_protocol
    end

    def ad_slot_url(include_protocol = false)
      if include_protocol
        attach_protocol("#{cdn_host}/adslots/va.ads.js")
      else
        "#{cdn_host}/adslots/va.ads.js"
      end
    end

    def ad_link_url
      attach_protocol("#{ad_link_host}/javascripts/va.adlinks.js")
    end

    def dynamic_tracking_host(main: false, adult: false)
      if main
        tracking_host
      elsif adult
        AlternativeDomain.adult_tracking_domain_hosts.sample || dynamic_tracking_host
      else
        [tracking_host, AlternativeDomain.tracking_domain_hosts].flatten.compact_blank.sample
      end
    end

    def dynamic_tracking_url(**options)
      attach_protocol(dynamic_tracking_host(**options))
    end

    def test_affiliate_id
      wl_setup(WlCompany::SETUP_KEYS_AFFILIATE_ID_FOR_TEST)
    end

    def missing_credit_affiliate_id
      wl_setup(WlCompany::SETUP_KEYS_AFFILIATE_ID_FOR_MISSING_CREDIT)
    end

    def test_network_id
      wl_setup(WlCompany::SETUP_KEYS_NETWORK_ID_FOR_TEST)
    end

    def test_affiliate
      Affiliate.cached_find(test_affiliate_id)
    end

    def missing_credit_affiliate
      Affiliate.cached_find(missing_credit_affiliate_id)
    end

    def catch_all_offer_id
      wl_setup(WlCompany::SETUP_KEYS_CATCH_ALL_OFFER_ID_FOR_NSA)
    end

    def catch_all_offer
      NetworkOffer.cached_find(catch_all_offer_id)
    end

    def test_network
      Network.cached_find(test_network_id)
    end

    def contact_emails
      ENV.fetch('CONTACT_EMAILS').split(',').compact
    end

    def tracking_server?
      SERVER_TYPE == 'TRACK'
    end

    def web_server?
      SERVER_TYPE == 'WEB'
    end

    def support_server?
      SERVER_TYPE == 'SUPPORT'
    end

    def db_on?
      wl_company.db_on?
    end

    private

    def attach_protocol(host)
      "#{protocol}://#{host}"
    end
  end
end
