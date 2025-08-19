class Api::V2::Affiliates::AdLinksController < Api::V2::Affiliates::BaseController
  skip_authorization_check

  def generate
    if current_user
      if @site_info = find_site_info
        skip = @site_info.page_url_opt_outs.any? do |exclude_url|
          params[:hostname].start_with?(exclude_url)
        end

        if skip
          respond_with({ data: {}, message: 'Opted out' }, status: 201)
        else
          url_map, domain_map = map_original_urls
          domains = domain_map.values.uniq.compact_blank.sort
          offer_map = query_offer_map(domains)
          offer_ids = offer_map.values.sort

          tracking_urls = generate_tracking_urls(url_map, domain_map, offer_map, [*domains, *offer_ids])

          Rails.logger.info "#{@site_info.hostname} => #{@site_info.affiliate_id}"
          Rails.logger.info tracking_urls

          respond_with({ data: tracking_urls }, status: 201)
        end
      else
        respond_with({ message: 'Web Property not found' }, status: 404)
      end
    else
      respond_with({ message: 'User not found' }, status: 404)
    end
  end

  private

  def current_user
    @current_user ||= Affiliate.cached_find(params[:affiliate_id])
    @current_user = nil unless @current_user&.active?
    @current_user
  end

  def require_params
    params.require(:affiliate_id)
    params.require(:hostname)
    params.require(:original_urls)
  end

  def map_original_urls
    url_map = {}
    domain_map = {}

    params[:original_urls].each do |key, value|
      url_map[key] = value

      next if @site_info.brand_domain_opt_outs.any? { |domain_opted| DotOne::Utils::Url.host_match?(domain_opted, value) }

      domain = DotOne::Utils::Url.host_name_without_www(value)
      domain_map[key] = domain if domain
    end

    [url_map, domain_map]
  end

  def find_site_info
    site_info = current_user.find_site_info_by_hostname(params[:hostname])

    if site_info.blank? && !SiteInfo.blacklisted?(params[:hostname]) && params[:original_urls].present?
      begin
        site_info = current_user.site_infos.create!(
          url: params[:hostname],
          description: SiteInfo::DESCRIPTION_AUTO_ADD_FROM_AD_LINK,
          media_category_id: AffiliateTag.media_categories.find_by_name('Blog').id,
        )
      rescue Exception => e
        Sentry.capture_exception(e)
      end
    end

    return unless site_info&.ad_link_enabled?

    site_info
  end

  def query_offer_map(domains)
    NetworkOffer.cached_for_ad_links.select { |domain, _| domains.include?(domain) }
  end

  def generate_tracking_urls(url_map, domain_map, offer_map, keys)
    fetch_cached_on_controller(*keys, Offer.cached_max_updated_at, AffiliateOffer.cached_max_updated_at) do
      tracking_urls = {}
      new_affiliate_offer_ids = []

      url_map.each_key do |original_key|
        domain = domain_map[original_key]
        offer_id = offer_map[domain]
        offer = NetworkOffer.cached_find(offer_id)

        tracking_urls[domain] = {
          tracking_url: nil,
        }

        next unless offer&.active?

        affiliate_offer = AffiliateOffer.best_match(current_user, offer)

        if offer.active_public? && (affiliate_offer.blank? || affiliate_offer.cancelled?)
          # Auto create affiliate_offer and activate it
          affiliate_offer = AffiliateOffer.best_match_or_create(current_user, offer, true)

          next unless affiliate_offer&.persisted?

          new_affiliate_offer_ids << affiliate_offer.id
        end

        next unless affiliate_offer&.active?

        tracking_urls[domain] = {
          tracking_url: affiliate_offer.to_tracking_url({
            t: '-href-',
            subid_1: 'adlinks',
            subid_2: @site_info.hostname,
            subid_3: '-link-id-',
            channel_id: params[:channel_id],
          }),
        }
      end

      # current_user.notify_affiliate_offer_invite(new_affiliate_offer_ids.uniq) if new_affiliate_offer_ids.present?

      tracking_urls
    end
  end
end
