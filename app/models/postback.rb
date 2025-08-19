class Postback < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include DateRangeable
  include Relations::AffiliateStatAssociated

  attr_reader :revenue, :order_total, :adv_uniq_id, :step_name, :currency_code, :method_detected, :status, :osc
  attr_accessor :order_number

  WHITE_LISTED_KEYS = [:adv_uniq_id, :currency_code, :order_number, :order_total, :revenue, :step_name, :method_detected, :status, :osc].freeze
  TYPES = ['Incoming', 'Outgoing']

  self.table_name = :dotone_postbacks
  self.primary_key = :id

  belongs_to_affiliate_stat
  belongs_to :conversion_stat, -> { AffiliateStat.conversions }, class_name: 'AffiliateStat', foreign_key: :affiliate_stat_id,
    optional: true

  validates :raw_request, uniqueness: { scope: :affiliate_stat_id }, if: :incoming?

  define_constant_methods TYPES, :postback_type

  # default_scope -> {
  #   where.not('raw_request LIKE ?', '%order=undefined%')
  #     .where.not('raw_request LIKE ?', '%order_total=undefined%')
  # }

  scope :unknown_click_id, -> { where('affiliate_stat_id LIKE ?', 'unknown%') }

  scope :like, -> (*args) {
    if args[0].present?
      result = nil

      args.flatten.each do |query|
        sanitized = sanitize_sql_like(query)
        current = where(
          'affiliate_stat_id LIKE :query OR id LIKE :query OR raw_request LIKE :query OR ip_address LIKE :query',
          query: "%#{sanitized}%"
        )

        if result
          result = result.or(current)
        else
          result = current
        end
      end

      result
    end
  }

  scope :query_by_order_number, -> (*args) {
    query = args.flatten.flat_map do |arg|
      ti, oid = arg.split(':')
      order_number = ERB::Util.url_encode(arg)
      terms = [
        "order=#{order_number}",
        "\"order\":\"#{order_number}\"",
        "ti=#{order_number}",
        "oid=#{order_number}"
      ]

      terms += ["ti=#{ti}", "oid=#{oid}"] if ti.present? && oid.present?

      terms
    end

    like(*query)
  }

  scope :api_excluded, -> {
    where.not('raw_request LIKE ?', 'http%://vbtrax.com/api%')
      .or(where('raw_request LIKE ?', 'http%://vbtrax.com/api/advertisers/orders/nine_one_app%'))
  }

  after_initialize :set_values

  def sanitized_affiliate_stat_id
    AffiliateStat.sanitize_stat_id(affiliate_stat_id)
  end

  def request_as_uri
    @request_as_uri ||= begin
      request = raw_request.to_s
        .gsub('modify.jsonapi', 'modify.json?api')
        .gsub('globalorder', 'global?order')
        .gsub('globalserver_subid', 'global?server_subid')
        .gsub('method_detected=POSTorder=', 'method_detected=POST&order=')

      if json_appended?(request)
        uri, query = parse_json_uri(request)
      else
        uri = URI(request)
        query = URI.decode_www_form(uri.query.to_s).to_h
      end

      [uri, query || {}]
    rescue
      global_url = 'https://vbtrax.com/track/postback/conversions/8/global'
      params = raw_request.to_s.gsub(global_url, '')

      begin
        query = JSON.parse(params)
        [URI(global_url), query]
      rescue JSON::ParserError
        []
      end
    end
  end

  def json_appended?(request)
    request.match(/\{.*\}/m)
  end

  def easy_store_webhook?
    raw_request.match?(/\/advertisers\/webhook\/easy_stores\//)
  end

  def parse_json_uri(request)
    match = request.match(/\{.*\}/m)
    uri_part = request.sub(match[0], '').strip
    json_part = match[0]
    method = request.match(/\&?method_detected=(POST|GET)/)

    uri = URI(uri_part)
    query = JSON.parse(json_part) rescue {}
    query['method_detected'] = method[1] if method

    [uri, query]
  end

  def order
    return unless click_stat = affiliate_stat || AffiliateStat.find_by_valid_subid(affiliate_stat_id)

    @order ||= if order_number.present?
      Order.find_by(affiliate_stat_id: click_stat.id, order_number: order_number)
    else
      found = Order
        .where(affiliate_stat_id: click_stat.id, step_name: step_name)
        .where('order_number LIKE ?', "AUTO-#{click_stat.network_id}-%")
        .last

      found ||= Order
        .where(affiliate_stat_id: click_stat.id)
        .where('order_number LIKE ?', "AUTO-#{click_stat.network_id}-%")
        .last

      found
    end
  end

  def fix_affiliate_stat_id
    self.update(affiliate_stat_id: AffiliateStat.sanitize_stat_id(affiliate_stat_id))
  end

  def recalculate_stat(pending_only: true)
    return unless  affiliate_stat.conversions?

    return if pending_only && !(affiliate_stat.pending? || affiliate_stat.invalid?)

    params = { revenue: revenue, order_total: order_total }
    options = {
      skip_currency_adjustment: false,
      skip_existing_commission: true,
      skip_existing_payout: true,
      currency_code: currency_code,
    }

    affiliate_stat.recalculate!(params, options)
  end

  def recalculate_order(force: false, pending_only: true)
    return if order.blank?
    return if step_name.blank? && !force
    return if step_name == order.step_name && !force
    return if DotOne::Utils.str_match?(step_name, order.step_name) && !force

    copy_stat = order.copy_stat

    return if pending_only && !(copy_stat.pending? || copy_stat.invalid?)

    params = { revenue: revenue, order_total: order_total, step: step_name }
    options = {
      skip_currency_adjustment: false,
      skip_existing_commission: true,
      skip_existing_payout: true,
      currency_code: currency_code,
      step_name_correction: !force,
    }

    order.copy_stat.recalculate!(params, options)
  end

  def retrigger!
    raise 'Click ID not found' unless new_affiliate_stat_id = sanitized_affiliate_stat_id

    uri, query = request_as_uri
    query['postback_retrigger'] = 'true'
    query['server_subid'] = new_affiliate_stat_id
    query['captured_at'] = recorded_at.to_s(:db).gsub("\s", '=')
    uri.query = URI.encode_www_form(query)

    request = Net::HTTP.get_response(uri)

    self.update!(affiliate_stat_id: new_affiliate_stat_id, raw_response: request.body)
  end

  def reflect_time!
    return unless order
    order.update!(recorded_at: recorded_at)
  end

  def delegate_adv_uniq_id
    return if adv_uniq_id.blank?
    return unless affiliate_stat

    if affiliate_stat.cached_offer&.single_conversion_point? && affiliate_stat.adv_uniq_id.blank?
      affiliate_stat.update(adv_uniq_id: adv_uniq_id)
    elsif affiliate_stat.cached_offer&.multi_conversion_point? && order&.copy_stat.present? && order.copy_stat.adv_uniq_id.blank?
      order.copy_stat.update(adv_uniq_id: adv_uniq_id)
    end
  end

  def set_values
    return if outgoing?

    _, query = request_as_uri

    return unless query

    @order_number = query['order'].presence || [query['ti'], query['oid']].compact_blank.join(':').presence
    @adv_uniq_id = query['adv_uniq_id'].presence
    @step_name = query['step'].presence || query['step_name']
    @revenue = query['revenue']
    @order_total = query['order_total'].presence || query['prtp']
    @currency_code = query['currency_code']
    @method_detected = query['method_detected']
    @status = query['status']
    @osc = query['osc']

    if easy_store_webhook?
      @adv_uniq_id = query['token'] || query.dig('order', 'token')
      @order_number = AffiliateStat.with_adv_uniq_ids(adv_uniq_id).first&.order
      @currency_code = query.dig('order', 'currency')
    end
  end

  def values
    WHITE_LISTED_KEYS.each_with_object({}) do |key, result|
      result[key] = send(key)
    end
    .compact_blank
  end
end
