module Track::CookieHandler
  COOKIE_NAME_PREFIX = {
    # network offer and offer variant
    # share the same prefix because they share
    # the same conversion pixels. Network offer
    # will browse through its offer variants to find
    # conversion tracking id from cookies
    network_offer: 'ov',
    offer_variant: 'ov',
  }

  def set_entity_cookie(click_stat)
    return if click_stat.blank?

    build_entity_cookies(click_stat)
    build_click_cookies_based_on_categories(click_stat)
  end

  def get_entity_cookie(entity)
    data = cookies[get_entity_cookie_key(entity)]

    # specific for network offers, grab its offer variants if no cookie.
    if data.blank? && entity.is_a?(NetworkOffer)
      entity.offer_variants.each do |ov|
        data = cookies[get_entity_cookie_key(ov)]
        break if data.present?
      end
    end
    data
  end

  private

  # cookie key to record the tracking entity for future reference, such as for conversion tracking
  def get_entity_cookie_key(entity)
    return if entity.blank?

    entity_type = entity.class.name.underscore.to_sym

    [
      COOKIE_NAME_PREFIX[entity_type],
      DotOne::Setup.wl_id,
      entity.id,
    ].join('_')
  end

  def build_entity_cookies(click_stat)
    # Real conversion expiration will be managed on conversion step
    expiration = 99.years.from_now.utc

    existing_transaction_id = cookies[get_entity_cookie_key(click_stat.entity)]

    # Record sibling transaction
    if existing_transaction_id
      DotOne::Kinesis::Client.to_kinesis(DotOne::Kinesis::TASK_ATTACH_SIBLING, {}, existing_transaction_id, click_stat.to_s)
    end

    cookies[get_entity_cookie_key(click_stat.entity)] = {
      value: click_stat.to_s,
      expires: expiration,
    }
  end

  def build_click_cookies_based_on_categories(click_stat)
    return if click_stat.blank?
    return unless offer = click_stat.offer
    return unless new_categories = offer.category_names.to_s.split(',').compact_blank.presence

    categories = cookies['click_categories'].to_s.split(',')
    categories = (new_categories | categories).flatten.compact_blank.uniq

    cookies['click_categories'] = {
      value: categories.join(','),
      expires: 99.years.from_now.utc,
    }
  end
end
