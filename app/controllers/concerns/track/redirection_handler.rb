module Track::RedirectionHandler
    ##
  # Method to pick default offer variant
  def use_default_offer_variant
    current_default_offer_variant if affiliate_available? && current_default_offer_variant.present? && affiliate_offer_available?
  end

  def use_campaign_backup_url
    current_affiliate_offer.backup_redirect if DotOne::Utils::Url.is_valid_url?(current_affiliate_offer&.backup_redirect)
  end

  def use_offer_backup_url
    current_offer.redirect_url if DotOne::Utils::Url.is_valid_url?(current_offer&.redirect_url)
  end

  def use_network_backup_url
    current_network.redirect_url if DotOne::Utils::Url.is_valid_url?(current_network&.redirect_url)
  end

  def obtain_alternative_redirection
    use_default_offer_variant || use_campaign_backup_url || use_offer_backup_url || use_network_backup_url
  end

  def go_to_alternate_destination
    alternative_destination = obtain_alternative_redirection

    if alternative_destination.is_a?(OfferVariant)
      @current_offer_variant = alternative_destination
      run_offer_click(skip_creatives: true)
    elsif alternative_destination.present?
      alternative_destination = interpolate_from_params(alternative_destination)
      token_formatter = DotOne::Track::TokenFormatter.new(alternative_destination, ClickStat.new(offer_id: current_offer&.id))
      alternative_destination = token_formatter.add_offer_info(params)
      redirect_to alternative_destination
    else
      redirect_to_terminal('No Alternative found', false) && return
    end
  end

  # Click logic that is used to determine certain action
  # depending on the availability of all entities involved in click tracking
  def determine_click_logic(click_runner, alternative_destination_runner, terminal_runner)
    if is_source_traffic_active? && (current_campaign || offer_available?)
      click_runner.call
    elsif current_affiliate_offer || current_offer || current_network
      alternative_destination_runner.call
    else
      terminal_runner.call
    end
  end

  private

  def redirect_to_terminal(error_message = nil, capture = true )
    notice = { message: error_message, url: request.original_url}
    Sentry.capture_exception(Exception.new("Click Terminated because #{notice}")) if capture
    redirect_to terminal_path, notice: notice
  end

  def redirect!(target_url)
    is_cloack = BooleanHelper.truthy?(params[:cloack]) || BooleanHelper.truthy?(current_offer.meta_refresh_redirect)
    is_social_media = AffiliateStat.is_facebook_bot?(request.env['HTTP_USER_AGENT'])

    if is_cloack || is_social_media
      render(
        'track/clicks/html_redirect',
        layout: false,
        locals: {
          offer: current_offer,
          target_url: target_url,
          is_cloack: is_cloack,
          is_social_media: is_social_media,
          pixels: is_cloack ? click_pixels(current_offer) : nil,
        },
      )
    else
      redirect_to(target_url, status: 301) && return
    end
  end

  def click_pixels(offer)
    return unless offer

    pixels = [offer.click_pixels, *offer.cached_category_groups.map(&:click_pixels)]
    pixels.flatten.compact_blank.join('')
  end
end
