class EasyStoreSetup < DatabaseRecords::PrimaryRecord
  include BecomePartnerStore
  include Relations::LanguageAssociated
  include Rails.application.routes.url_helpers

  attr_accessor :code

  def platform
    'easystore'
  end

  def install_pixels!
    return if snippet_identifier.present? || mkt_site.blank?

    response = api.create_snippet(browse_pixel_string)

    snippet_identifier = response.dig('snippet', 'id')
    update(snippet_identifier: response.dig('snippet', 'id')) if snippet_identifier.present?

    self
  end

  def install_order_update_webhook!
    return if order_update_webhook_identifier.present?

    url = update_api_v2_advertisers_webhook_easy_stores_url(host: DotOne::Setup.advertiser_api_host)

    response = api.create_webhook(url, 'order/update')

    webhook_id = response.dig('webhook', 'id')
    update(order_update_webhook_identifier: webhook_id) if webhook_id.present?

    self
  end

  def install_order_cancel_webhook!
    return if order_cancel_webhook_identifier.present?

    url = reject_api_v2_advertisers_webhook_easy_stores_url(host: DotOne::Setup.advertiser_api_host)

    response = api.create_webhook(url, 'order/cancel')

    webhook_id = response.dig('webhook', 'id')
    update(order_cancel_webhook_identifier: webhook_id) if webhook_id.present?

    self
  end

  def retrieve_store!
    response = api.retrieve_store
    assign_attributes(
      access_token: api.access_token,
      store_name: response.dig('store', 'name'),
      store_title: response.dig('store', 'title'),
      time_zone_id: (TimeZone.cached_find_by(gmt_string: response.dig('store', 'timezone', 'offset')) || TimeZone.platform).id,
      currency_id: (Currency.cached_find_by(code: response.dig('store', 'currency')) || Currency.platform).id,
      language_id: (Language.cached_find_by(code: response.dig('store', 'primary_locale')&.sub('_', '')) || Language.platform).id,
      email: response.dig('store', 'customer_email'),
    )
  end

  def api
    @api ||= DotOne::ApiClient::ApiWorker::EasyStore.new(
      code: code,
      access_token: access_token,
      store_domain: store_domain,
    )
  end

  def deploy_assets!
    install_pixels!
    install_order_update_webhook!
    install_order_cancel_webhook!
  end

  def deployed?
    snippet_identifier? && order_update_webhook_identifier? && order_cancel_webhook_identifier? && order_delete_webhook_identifier?
  end

  def default_url_options
    Rails.application.config.action_mailer[:default_url_options]
  end
end
