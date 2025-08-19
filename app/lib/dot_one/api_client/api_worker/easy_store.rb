require 'openssl'

class DotOne::ApiClient::ApiWorker::EasyStore
  attr_accessor :code, :access_token, :base_url, :headers

  def initialize(code: nil, access_token: nil, store_domain: nil)
    @code = code
    @access_token = access_token
    @base_url = build_base_url(store_domain)
    @headers = { 'Content-Type' => 'application/json' }

    build_access_token
  end

  def self.hmac_valid?(hmac, message)
    hmac == OpenSSL::HMAC.hexdigest('sha256', ENV.fetch('EASY_STORE_CLIENT_SECRET'), message)
  end

  def retrieve_store
    res = client.request(:get, '/api/3.0/store.json', headers: headers)
    JSON.parse(res.body)
  end

  def create_snippet(browser_pixel)
    body = {
      snippet: {
        field: 'global/body_end',
        value: browser_pixel,
      },
    }
    res = client.request(:post, '/api/3.0/snippets.json', body: body.to_json, headers: headers)

    JSON.parse(res.body)
  end

  def create_webhook(url, topic)
    body = {
      webhook: {
        url: url,
        topic: topic,
      },
    }
    res = client.request(:post, '/api/3.0/webhooks.json', body: body.to_json, headers: headers)

    JSON.parse(res.body)
  end

  private

  def client
    @client ||= ::OAuth2::Client.new(
      ENV.fetch('EASY_STORE_CLIENT_ID'),
      ENV.fetch('EASY_STORE_CLIENT_SECRET'),
      site: base_url,
      authorize_url: nil,
      token_url: '/api/3.0/oauth/access_token.json',
      token_method: :post,
    )
  end

  def build_base_url(domain)
    uri = URI.parse('')
    uri.host = domain
    uri.scheme = 'https'
    uri.to_s
  end

  def build_access_token
    unless access_token
      body = {
        code: code,
        client_id: client.id,
        client_secret: client.secret,
      }

      res = client.request(:post, '/api/3.0/oauth/access_token.json', body: body.to_json, headers: headers)
      body = JSON.parse(res.body)

      @access_token = body['access_token']
    end

    @headers['EasyStore-Access-Token'] = @access_token
  end
end
