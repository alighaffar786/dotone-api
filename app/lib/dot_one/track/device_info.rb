class DotOne::Track::DeviceInfo
  attr_reader :url

  def initialize(user_agent:, full_path: nil, ip: nil)
    @user_agent = URI::Parser.new.escape(user_agent)
    @url = URI("https://cloud.51degrees.com/api/v1/#{ENV.fetch('FIFTY_ONE_DEGREE_KEY')}/match?user-agent=#{@user_agent}")
    @formatted_device_info = nil
    @full_path = full_path
    @ip = ip
  end

  ## Don't call this method, use #formatted_device_info instead.
  ## This method calls 51 degree's API, formats data and sets the result to @formatted_device_info for later usage,
  ## so we don't have to keep calling the API.
  def process_data
    @formatted_device_info = call_51_degree.tap do |d|
      d['device_model'] = map_device_model_name(d)
      d['device_brand'] = d.dig('Values', 'HardwareVendor', 0)
      d['device_type'] = map_device_type(d.dig('Values', 'IsMobile', 0))
      d['device_os'] = d.dig('Values', 'PlatformName', 0)
      d['device_os_version'] = d.dig('Values', 'PlatformVersion', 0)
      d['browser'] = d.dig('Values', 'BrowserName', 0)
      d['browser_version'] = d.dig('Values', 'BrowserVersion', 0)

      capture_user_agent(device_info: d)
    end.with_indifferent_access
  end

  def capture_user_agent(device_info:)
    return if @full_path.blank?

    is_bot = device_info['browser'].to_s.downcase.match?(/bot|crawler|spider/)
    is_conversion_path = TRACK_CONVERSION_PATH_REGEX.match?(@full_path)
    bots_by_whitelist = [BOTS_BY_IP_WHITELIST[@ip], BOTS_BY_WHITELIST].flatten.uniq.compact_blank

    bot_match = -> (bot) { @user_agent.to_s.downcase.include?(bot.to_s.downcase) }

    is_undetected_bot = ((!is_conversion_path && (is_bot && !bots_by_whitelist.any?(&bot_match))) || (is_conversion_path && !POSTBACK_WHITELISTED_USER_AGENTS.any?(&bot_match)))

    if is_undetected_bot
      cache_key = DotOne::Utils.to_cache_key('user_agent', @fullpath, @user_agent)
      is_cached = Rails.cache.read(cache_key).present?

      unless is_cached
        Sentry.capture_exception(Exception.new("crawler alert: #{@user_agent}"))
        Rails.cache.write(cache_key, 1, expires_in: 1.month)
      end
    end
  end

  def to_data_for_tracking
    data_for_tracking = formatted_device_info.dup
    data_for_tracking['device'] = data_for_tracking
    data_for_tracking
  rescue StandardError
  end

  def formatted_device_info
    @formatted_device_info.presence || process_data
  end

  # This method RETURNS an OFFER_VARIANT if NOT VIOLATE any filter, OTHERWISE it returns TRUE
  # TO USE: supply the offer variant as the only argument.
  # checked_ov and api_data are created within this method when recursive(last line)
  # Every time recursion happened, the offer_variant's id is added to check_ov, we exclude these when querying for siblings
  # api_data is 51 degree response, we pass it to recursion to prevent callings API too many times
  def violate_device_filters?(offer_variant, checked_ov = [], api_data = nil, affiliate = nil)
    exclude_ovs = checked_ov << offer_variant.id
    violate = false
    device_info = nil

    begin
      device_info = api_data.present? ? api_data : formatted_device_info.dup
    rescue Exception => e
      violate = false
    end

    filters = offer_variant.cached_device_filters
    violate = check_allow_n_deny_filters(device_info, filters)

    return offer_variant unless violate

    ### if filters are violated, should proceed to check siblings offer variant
    affiliate_offer = AffiliateOffer.active_best_match(affiliate, offer_variant.cached_offer)

    siblings_ov = offer_variant.cached_offer.cached_active_offer_variants.reject do |ov|
      exclude_ovs.include?(ov.id) || (ov.active_private? && affiliate_offer.blank?)
    end

    return true if siblings_ov.blank?

    violate_device_filters?(siblings_ov.first, exclude_ovs, device_info, affiliate)
  end

  private

  def call_51_degree
    hash_key = Digest::SHA1.hexdigest(@user_agent)
    ckey = DotOne::Utils.to_cache_key(self, hash_key, :call_51_degree)
    DotOne::Cache.fetch(ckey) do
      response = URI.open(url, read_timeout: 3).read
      JSON.parse(response)
    end
  end

  def check_allow_n_deny_filters(device_info, filters)
    return if device_info.blank?

    ['user_device_type', 'user_device_model_name', 'user_device_brand_name'].each do |key|
      device_info_key, allows, denies = collect_parties_of_comparison(key, filters)

      if not_in_allowed_list?(device_info.dig(device_info_key), allows) ||
          in_denies_list?(device_info.dig(device_info_key), denies)
        return true
      end
    end

    os_version_compatible?(device_info, filters) ? false : true
  end

  def collect_parties_of_comparison(key, filters)
    filter_key = key.gsub('user', 'target').to_sym
    device_info_key = key.gsub('user_', '').to_sym
    allows = filters.dig(:allow, filter_key).map(&:downcase)
    denies = filters.dig(:deny, filter_key).map(&:downcase)
    [device_info_key, allows, denies]
  end

  def os_version_compatible?(device_info, filters)
    key = 'user_device_os_version'
    client_os_version = DotOne::Utils::SemanticVersion.new(device_info['device_os_version'])
    _device_info_key, allows, denies = collect_parties_of_comparison(key, filters)

    allows = DotOne::Utils::SemanticVersion.string_ver_to_semantic_ver(allows)
    denies = DotOne::Utils::SemanticVersion.string_ver_to_semantic_ver(denies)

    allows_range = simplify_version_list(allows)
    denies_range = simplify_version_list(denies)

    if (allows_range.present? && !client_os_version.between?(allows_range[0], allows_range[1])) ||
        (denies_range.present? && client_os_version.between?(denies_range[0], denies_range[1]))
      false
    else
      true
    end
  end

  ## Take in an array of version and convert it to a range
  # Ex: [[2.0, 3.5], [1.3, 2.5]] #=> [1.3, 3.5]
  def simplify_version_list(array)
    return [] if array.blank?

    array.each_with_object([]) do |data, default|
      default[0] = data[0] if default[0].blank? || (data[0] < default[0])
      default[1] = data[1] if default[1].blank? || (data[1] > default[1])
    end
  end

  def not_in_allowed_list?(item, list)
    return false if list.blank? || item.blank?

    items = [item].flatten.map(&:downcase)
    lists = [list].flatten.map(&:downcase)
    (items & lists).blank?
  end

  def in_denies_list?(item, list)
    return false if list.blank?

    items = [item].flatten.map(&:downcase)
    lists = [list].flatten.map(&:downcase)
    (items & lists).present?
  end

  def map_device_model_name(data)
    hardware_name = begin
      data['Values']['HardwareName'].first
    rescue StandardError
    end
    hardware_model = begin
      data['Values']['HardwareModel'].first
    rescue StandardError
    end
    os_model = begin
      data['Values']['PlatformName'].first
    rescue StandardError
    end

    [hardware_name, hardware_model, os_model, 'v2'].compact_blank.uniq
  end

  def map_device_type(string)
    return 'Mobile' if string == 'True'

    'Desktop'
  end
end
