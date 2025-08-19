module EmailHelper
  # email translate
  def et(key, options = {})
    order = options[:sc_order]
    delivery = options[:sc_order_delivery]
    opt = { locale: options[:locale] }

    if order.present?
      opt[:site_name] = order.lg_domain.site_name
      opt[:order_number] = order.order_number
      opt[:cs_email] = order.lg_domain.cs_email
      opt[:cs_phone] = order.lg_domain.cs_phone
      opt[:shipping_name] = order.lg_lead.info_shipping_full_name
      opt[:shipping_address] = t('address.formats.html', address: order.lg_lead.info_shipping_address,
        city: order.lg_lead.shipping_city, state: order.lg_lead.shipping_state, locale: options[:locale])
      opt[:shipping_phone] = order.lg_lead.info_shipping_phone
      opt[:billing_name] = order.lg_lead.info_billing_full_name
      opt[:billing_address] = t('address.formats.html', address: order.lg_lead.info_billing_address,
        city: order.lg_lead.billing_city, state: order.lg_lead.billing_state, locale: options[:locale])
      opt[:table] = render('sc/sc_orders/invoice.html', sc_order: order, render_for: 'email')
      opt[:locale] = order.language.code
    end

    if order.present? && delivery.present?
      opt[:shipped_at] = l(delivery.shipped_at, locale: order.language.code, format: :default)
      opt[:shipped_via] = delivery.via
      opt[:tracking_number] = delivery.tracking_number
    end

    raw(t(key, opt))
  end

  def affiliate_offers_url_block(affiliate, affiliate_offers)
    return if affiliate_offers.blank?

    affiliate_offers = affiliate_offers.dup
    block = affiliate_offers.shift(3).map do |affiliate_offer|
      offer = affiliate_offer.cached_offer
      ActionController::Base.helpers.link_to(offer.id_with_name,
        DotOne::ClientRoutes.affiliates_offer_url(offer.id, locale: affiliate.locale), target: '_blank')
    end.join('<br>')

    if affiliate_offers.shift(3).present?
      block << '<br>'
      block << ActionController::Base.helpers.link_to(
        "And #{affiliate_offers.size} more",
        DotOne::ClientRoutes.affiliates_my_offers_url,
        target: '_blank',
      )
    end

    block
  end

  def network_stat_summary_currency(network, original_amount)
    network_currency_code = network.currency_code
    format = '%u %n'
    original_currency = number_to_currency(original_amount.to_f.round(2), unit: Currency.platform_code, format: format)

    if network_currency_code == Currency.platform_code
      original_currency
    else
      rate = Currency.rate(Currency.platform_code, network_currency_code)
      converted_amount = (rate * original_amount.to_f).round(2)
      converted_currency = number_to_currency(converted_amount, unit: network_currency_code, format: format)

      "#{original_currency}/#{converted_currency}"
    end
  end

  def html_formatted(content, options = {})
    return '' if content.blank?

    sanitize_options = {
      attributes: SAFE_HTML_ATTRIBUTES,
    }

    sanitize_options[:attributes] = options[:attributes] if options[:attributes]

    sanitize_options[:tags] = options[:tags] if options[:tags]

    content = content.gsub(/\r\n/, '<br/>') unless options[:convert_new_line] == false

    content = strip_tags(content) if options[:html_out] == false

    if options[:max_chars].present? && content.length > options[:max_chars].to_i
      content = content[0, options[:max_chars].to_i] + '...'
      more_text = options[:text_for_more] || 'more'
      content += link_to(more_text.html_safe, options[:url_to_more]) if options[:url_to_more].present?
    end

    sanitize(raw(content), sanitize_options)
  end
end
