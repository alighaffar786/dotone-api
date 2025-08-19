class DotOne::Middleware::BotBlocker
  def initialize(app)
    @app = app
    bots = YAML.load_file(Rails.root.join('data', 'bots.yml'))

    @blocked_user_agents = bots['blocked_user_agents'].map(&:downcase)
    # @postback_blocked_user_agents = bots['postback_blocked_user_agents'].map(&:downcase)
    @postback_blocked_user_agents = []
    @blocked_ip_addresses = bots['blocked_ip_addresses']
    @whitelisted_ip_addresses = bots['whitelisted_ip_addresses']
    @referrers = bots['referrers'].map(&:downcase)
    @whitelisted_user_agents = bots['whitelisted_user_agents'].map(&:downcase)
    @postback_whitelisted_user_agents = bots['postback_whitelisted_user_agents'].map(&:downcase)
    @blocked_ad_link_referers = bots['blocked_ad_link_referers'].map(&:downcase)
  end

  def call(env)
    @request = Rack::Request.new(env)

    request_params = @request.params.symbolize_keys

    possible_conversion = request_params.key?(:conversions) || request_params.key?(:conversion) || request_params.key?(:order) || request_params.key?(:order_total) || @request.path.include?('conversion')

    if !possible_conversion && track_blocked?
      return [
        403,
        { 'Content-Type' => 'text/plain' },
        ['Access forbidden for bots.']
      ]
    end

    @app.call(env)
  end

  private

  def track_blocked?
    path_blocked = [
      '/track/clicks', '/track/imp/', '/terminal', '/r/', '/track/affr/',
      '/track/slot', '/api/v2/affiliates/links/generate', '/api/v2/affiliates/ad_links/generate',
    ].any? { |path| @request.path.start_with?(path) }

    return false unless path_blocked

    if @request.ip.to_s.start_with?('213.')
      Rails.logger.error @request.user_agent
    end

    if @request.path.start_with?('/track/imp/mkt_site/') && (blocked_user_agent? || whitelisted_user_agent?)
      Rails.logger.error @request.user_agent
    end

    return false if whitelisted_user_agent?
    return false if whitelisted_ip_address?

    blocked_user_agent? || blocked_ip? || blocked_referrer? || blocked_ad_link_referer?
  end

  def postback_blocked?
    path_blocked = ['/api'].any? { |path| @request.path.start_with?(path) } || TRACK_CONVERSION_PATH_REGEX.match?(@request.path)
    api_ua_blocked = @postback_blocked_user_agents.any? { |ua| user_agent_matched?(ua) }

    path_blocked && api_ua_blocked && log(__method__)
  end

  def path_whitelisted?
    [
      /\/track\/clicks\/(\d)+\/.*/,
    ].any? { |path| @request.path.match?(path) }
  end

  def whitelisted_user_agent?
    @whitelisted_user_agents.any? { |bot| user_agent_matched?(bot) }
  end

  def whitelisted_ip_address?
    @whitelisted_ip_addresses[@request.ip].present?
  end

  def whitelisted_postback_user_agent?
    # path_matched = TRACK_CONVERSION_PATH_REGEX.match?(@request.path)
    # whitelisted = @postback_whitelisted_user_agents.any? { |bot| user_agent_matched?(bot) }

    # path_matched && whitelisted
    true
  end

  def blocked_ip?
    @blocked_ip_addresses.any? { |ip| @request.ip == ip } && log(__method__)
  end

  def blocked_referrer?
    @referrers.any? { |referrer| @request.referer.to_s.downcase.include?(referrer) } && log(__method__)
  end

  def blocked_user_agent?
    @blocked_user_agents.any? { |ua| user_agent_matched?(ua) }
  end

  def user_agent_matched?(ua)
    @request.user_agent.to_s.downcase.include?(ua.to_s.downcase)
  end

  def blocked_ad_link_referer?
    @blocked_ad_link_referers.any? { |referer| @request.referer.to_s.downcase.include?(referer) } && log(__method__)
  end

  def log(name)
    Rails.logger.info("restrict by: #{name}")
    true
  end
end
