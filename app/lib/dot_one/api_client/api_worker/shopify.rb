require 'net/https'
require 'open-uri'

class DotOne::ApiClient::ApiWorker::Shopify
  include Rails.application.routes.url_helpers

  attr_reader :setup

  def initialize(setup)
    @setup = setup
  end

  # URI
  def create_uri(path)
    URI::HTTPS.build({
      host: setup.store_domain,
      path: path,
    })
  end

  # HTTP
  def create_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    # Prevent longer than 5 second API request
    # to bog down the servers
    http.read_timeout = 5
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def send_post(path, params = {})
    uri = create_uri(path)
    http = create_http(uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['X-Shopify-Access-Token'] = setup.access_token
    request['Accept'] = 'application/json'
    request.content_type = 'application/json'
    request.body = params.to_json
    response = http.request(request)
    process_response(response)
  end

  def send_delete(path, params = {})
    uri = create_uri(path)
    uri.query = params.to_param
    http = create_http(uri)
    request = Net::HTTP::Delete.new(uri.request_uri)
    request['X-Shopify-Access-Token'] = setup.access_token
    request['Accept'] = 'application/json'
    request.content_type = 'application/json'
    process_response(http.request(request))
  end

  def get_access_token
    uri = create_uri('/admin/oauth/access_token')
    http = create_http(uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
      client_id: SHOPIFY_API_KEY,
      client_secret: SHOPIFY_API_SECRET_KEY,
      code: setup.authorization_code,
    })
    response = http.request(request)
    process_response(response)
  end

  def create_script_tag
    send_post('/admin/api/2020-10/script_tags', {
      script_tag: {
        event: 'onload',
        src: setup.script_tag_file_url,
      },
    })
  end

  def create_order_update_webhook
    send_post('/admin/api/2020-10/webhooks', {
      webhook: {
        topic: 'orders/updated',
        address: webhook_order_update_api_v1_advertisers_shopifies_url(
          host: DotOne::Setup.advertiser_api_host,
          protocol: 'https',
        ),
        format: 'json',
      },
    })
  end

  def create_order_delete_webhook
    send_post('/admin/api/2020-10/webhooks', {
      webhook: {
        topic: 'orders/delete',
        address: webhook_order_delete_api_v1_advertisers_shopifies_url(
          host: DotOne::Setup.advertiser_api_host,
          protocol: 'https',
        ),
        format: 'json',
      },
    })
  end

  def create_order_cancel_webhook
    send_post('/admin/api/2020-10/webhooks', {
      webhook: {
        topic: 'orders/cancelled',
        address: webhook_order_cancel_api_v1_advertisers_shopifies_url(
          host: DotOne::Setup.advertiser_api_host,
          protocol: 'https',
        ),
        format: 'json',
      },
    })
  end

  def delete_webhook(id)
    send_delete("/admin/api/2020-10/webhooks/#{id}")
  end

  def process_response(response)
    JSON.parse(response.body)
  rescue StandardError
  end
end
