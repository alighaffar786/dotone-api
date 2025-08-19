require 'libxml'
require 'net/https'
require 'multi_json'
require 'open-uri'

class AffiliateStat < DatabaseRecords::PrimaryRecord
  include AffHashable
  include BulkInsertable
  include ChangesStore
  include Traceable
  include AffiliateStatHelpers::Common
  include AffiliateStatHelpers::ConversionProcess
  include DotOne::Kinesis::Streamable

  PARTITIONS = [AffiliateStatCapturedAt, AffiliateStatPublishedAt, AffiliateStatConvertedAt]

  attr_accessor :margin, :request, :response

  accepts_nested_attributes_for :orders

  after_initialize :generate_id
  before_validation :set_defaults
  before_save :adjust_values
  after_save :mirror_to_redshift, :update_order_related
  after_update :touch_partitions, if: :flag_changed?
  after_touch :touch_partitions
  after_destroy :delete_from_redshift, :delete_from_other_partitions
  after_commit :queue_refresh_conversion_step_snapshot, on: :create
  after_commit :queue_fire_s2s_routine, on: :create
  after_commit :queue_fire_s2s_confirmed_routine, on: :update

  set_predefined_flag_attributes :conversion_steps
  set_predefined_flag_attributes :exceed_cap_check, :html_pixel_fired, :s2s_fired, :confirmed_s2s_fired, type: :boolean
  set_predefined_flag_attributes :confirmed_s2s_fired_amount, :s2s_fired_amount, type: :integer

  trace_has_many_includes :orders

  scope :using_partition, -> (*args) {
    if args.present? && args[0].present?
      from("affiliate_stats FORCE INDEX(index_affiliate_stats_on_#{args[0]})")
    end
  }

  scope :grouped, -> (*args) {
    groups = args[0]
    avail_columns = args[1]
    columns = groups & avail_columns
    group(columns.join(',')) if columns.present?
  }

  # This is to break result by date
  # and showing null when date has no data.
  # source: http://stackoverflow.com/questions/13754598/mysql-show-all-dates-between-even-if-no-result
  scope :daily, -> (*args) {
    start_at = args[0].is_a?(String) ? Date.parse(args[0]) : args[0]
    end_at = args[1].is_a?(String) ? Date.parse(args[1]) : args[1]
    time_zone = args[2].present? ? args[2] : TimeZone.default

    # args[3] is an ActiveRecord Relation
    relations = begin
      args[3].to_sql
    rescue StandardError
    end
    joining_entity = []
    joining_entity << "(#{relations}) AS" if relations.present?
    joining_entity << 'affiliate_stats'
    joining_entity = joining_entity.join(' ')

    query_start_at = start_at - 1.day
    number_of_days = (end_at - query_start_at).to_i / 1.day

    temp_day_sql = <<-SQL
      ( SELECT @curDate := Date_Add(@curDate, interval 1 day) as date
        FROM (select @curDate := '#{query_start_at.to_date.to_s(:db)}') sqlvars, affiliate_stats
        LIMIT #{number_of_days}
      ) as temp_days
    SQL

    join_sql = <<-SQL
      LEFT JOIN #{joining_entity} ON
        DATE(
          CONVERT_TZ(affiliate_stats.recorded_at, '+00:00', '#{time_zone.gmt_string}')
        ) = temp_days.date
    SQL

    select('temp_days.date as recorded_at')
      .from(temp_day_sql)
      .joins(join_sql)
      .group('temp_days.date')
  }

  scope :with_order_number, -> { where.not(order_number: nil) }
  scope :test_subids, -> { where('subid_1 LIKE ?', 'test%') }
  scope :latest, -> { order(recorded_at: :desc) }

  delegate :name, to: :offer, prefix: true, allow_nil: true

  [:device_os, :device_os_version].each do |name|
    define_method name do
      return unless device_info
      device_info[name.to_s]
    end
  end

  def self.test_run?(value)
    value.present? && value.downcase.start_with?('test')
  end

  def self.valid_id?(value)
    MD5_REGEX.match?(value.to_s)
  end

  def self.find_by_valid_subid(value)
    return if value.blank? || !valid_id?(value)

    self.clicks.find_by(subid_1: value)
  end

  def self.approval_status_map
    {
      AffiliateStat.approval_approved => [
        Order.status_approved,
        Order.status_confirmed
      ],
      AffiliateStat.approval_adjusted => [
        Order.status_adjusted
      ],
      AffiliateStat.approval_published => [
        Order.status_published
      ],
      AffiliateStat.approval_rejected => [
        Order.status_rejected,
        Order.status_duplicate_order,
        Order.status_duplicate_ip,
        Order.status_duplicate_advertiser_uniq_id
      ],
      AffiliateStat.approval_full_return => [
        Order.status_full_return
      ],
      AffiliateStat.approval_pending => [
        Order.status_pending,
        Order.status_manual_credit,
        Order.status_test_conversion,
        Order.status_manual_approval,
      ],
      AffiliateStat.approval_invalid => [
        Order.status_invalid,
        Order.status_beyond_referral_period,
        Order.status_exceed_cap,
        Order.status_suppressed,
        Order.status_no_active_campaign,
        Order.status_negative_margin,
      ]
    }
  end

  def self.approvals(user_role = nil)
    if user_role == :affiliate
      [
        approval_approved,
        approval_pending,
        approval_rejected,
        approval_invalid,
        approval_adjusted,
        approval_full_return,
      ]
    else
      [
        approval_approved,
        approval_published,
        approval_pending,
        approval_rejected,
        approval_invalid,
        approval_adjusted,
        approval_full_return,
      ]
    end
  end

  def self.approvals_considered_pending(user_role = nil)
    if user_role == :network
      [
        approval_pending,
        approval_invalid,
      ]
    else
      [
        approval_pending,
      ]
    end
  end

  def self.approvals_publishable
    [
      approval_published,
      approval_approved,
      approval_adjusted,
    ]
  end

  def self.approvals_considered_final(user_role = nil)
    if user_role == :network
      [
        approval_published,
        approval_approved,
        approval_adjusted,
      ]
    else
      [
        approval_published,
        approval_approved,
        approval_adjusted,
        approval_rejected,
        approval_full_return,
      ]
    end
  end

  ##
  # Collection of approval status that are considered
  # as positives
  def self.approvals_positive
    [
      approval_published,
      approval_approved,
      approval_adjusted,
    ]
  end

  def self.approvals_considered_approved(user_role = nil)
    if user_role == :network
      [
        approval_adjusted,
        approval_approved,
        approval_published,
      ]
    else
      [
        approval_adjusted,
        approval_approved,
      ]
    end
  end

  def self.approvals_considered_rejected
    [
      approval_rejected,
      approval_full_return,
    ]
  end

   def self.decide_approval(order_status)
    approval_status_map.select { |approval, statuses| statuses.include?(order_status) }.keys.first || approval_pending
  end

  def self.decide_status(approval)
    approval_status_map[approval]&.first
  end

  def self.is_bot?(http_user_agent, ip_address, referrer)
    return false if http_user_agent.blank? && ip_address.blank?

    if http_user_agent
      ALL_BOTS.each do |str|
        match = http_user_agent.downcase.include?(str)

        if match == true
          if whitelisted_user_agents = BOTS_BY_IP_WHITELIST[ip_address].presence
            return whitelisted_user_agents.none? { |str| http_user_agent.include?(str) }
          else
            return true
          end
        end
      end
    end

    if ip_address
      BOTS_BY_IP_ADDRESSES.each do |ip|
        return true if ip == ip_address
      end
    end

    if referrer
      BOTS_BY_REFERRER.each do |str|
        return true if DotOne::Utils::Url.host_match?(referrer.downcase, str)
      end
    end

    false
  end

  def self.is_facebook_bot?(http_user_agent)
    http_user_agent =~ /facebookexternalhit/
  end

  ##
  # Method to handle conversion import
  def self.import_conversions(upload_id, options = {})
    importer = DotOne::AffiliateStats::Importer.new(upload_id, options)
    importer.import
  end

  def self.approved_conversions_for_affiliates(affiliate_ids, start_at, end_at)
    AffiliateStatConvertedAt
      .conversions
      .with_affiliates(affiliate_ids)
      .between(start_at, end_at, :converted_at, TimeZone.platform)
      .where(approval: AffiliateStat.approvals_considered_approved)
  end

  def self.sanitize_stat_id(stat_id)
    stat_id.to_s.split(/[^0-9a-zA-Z]/).reject(&:blank?).first.presence || stat_id
  end

  def self.record_hits(*args)
    DotOne::AffiliateStats::Recorder.record_hits(*args)
  end

  def self.bulk_save_clicks(value_array)
    DotOne::AffiliateStats::Recorder.bulk_save_clicks(value_array)
  end

  def self.record_clicks(*args)
    DotOne::AffiliateStats::Recorder.record_clicks(*args)
  rescue Exception => e
    offer_variant, tracking_token, tracking_data, options = args
    sliced_tracking_data = tracking_data.slice(*[*AffiliateStat.column_names, :rid, :RID, :ip_address, :token, :mkt_site])

    AffiliateStats::ClickJob.perform_later(
      offer_variant.id,
      sliced_tracking_data.to_h,
      options,
    )
    Sentry.capture_exception(e, extra: sliced_tracking_data.merge({ offer_variant_id: offer_variant.id }))

    raise e
  end

  def self.save_click!(values_to_save)
    return if values_to_save.blank?

    AffiliateStat.find_by_id(values_to_save[:id])&.destroy if values_to_save[:id].present?

    entity = AffiliateStat.new(values_to_save)
    entity.save!
  end

  ##############
  # CONVERSIONS
  ##############

  def self.refresh_conversion_step_snapshot!(stat_id)
    affiliate_stat = AffiliateStat.find_by_id(stat_id)
    affiliate_stat.refresh_conversion_step_snapshot! if affiliate_stat
  end

  def self.extract_attributes(stat)
    stat.attributes
      .reject { |key, _value| ['id'].include?(key) }
      .to_h do |column, value|
        new_value = value && columns_hash[column].type == :json ? value.to_json : value
        [column, new_value]
      end
  end

  def valid_statuses
    AffiliateStat.approval_status_map[approval] || []
  end

  def copy_stats
    if clicks?
      AffiliateStat.where(order_id: order_ids)
    else
      AffiliateStat.none
    end
  end

  def forex
    @forex ||= self[:forex].presence || sibling_forex_rates
  end

  def sibling_forex_rates
    copy_stats.first(10).find { |stat| stat.forex.present? }&.forex
  end

  def store_device_information(device)
    return unless device.present?

    device_type = 'Desktop'
    device_type = 'Mobile' if device['is_wireless_device'] == true
    device_type = 'Tablet' if device['is_tablet'] == true
    self.device_type = device_type
    self.device_brand = device['brand_name']
    self.device_model = device['marketing_name']

    save
  end

  def refresh_conversion_step_snapshot!(enforce = false)
    return unless clicks?
    return if conversion_steps.present? && !enforce

    if test_run?
      found_affiliate_offer = affiliate_offer || AffiliateOffer.new(offer_id: offer_id, affiliate_id: affiliate_id)
    else
      return if affiliate_offer_id.blank?
      found_affiliate_offer = affiliate_offer
    end

    self.conversion_steps = found_affiliate_offer.related_conversion_point_information
    self.conversion_steps
  end

  def queue_refresh_conversion_step_snapshot(**options)
    if Rails.env.production?
      AffiliateStats::RecordConversionStepSnapshotJob.perform_later(id, **options)
    else
      refresh_conversion_step_snapshot!
    end
  end

  def update_order!(params = {})
    return if order_id.blank?

    order_to_update = copy_order
    copy_status = copy_order.status

    if valid_statuses.exclude?(copy_status)
      copy_status = valid_statuses.first
    end

    order_total_to_use = order_total if order_total.to_f > 0
    order_total_to_use ||= order_to_update.total if order_to_update.total.to_f > 0

    if order_total_to_use
      calculated_affiliate_share = DotOne::Utils.to_percentage(affiliate_pay, order_total_to_use).round(2)
      calculated_true_share = DotOne::Utils.to_percentage(true_pay, order_total_to_use).round(2)
    end

    to_updates = {
      true_pay: true_pay,
      true_share: calculated_true_share,
      affiliate_pay: affiliate_pay,
      affiliate_share: calculated_affiliate_share,
      status: copy_status,
      published_at: published_at,
      converted_at: converted_at,
      forex: forex,
      original_currency: original_currency,
      step_name: step_name,
      total: order_total_to_use
    }

    to_updates.merge!(params)

    update_to_trace = to_updates
      .to_h do |key, value|
        order_value = order_to_update.send(key)
        order_value = order_value.to_f if order_value.is_a?(BigDecimal)
        value = value.to_f if value.is_a?(BigDecimal)
        values = [order_value, value].uniq
        [key, values.size == 1 ? nil : values]
      end
      .compact

    return if update_to_trace.blank?

    Order.where(id: order_to_update.id).update_all(to_updates.merge(updated_at: Time.now,))

    order_to_update.trace!(Trace::VERB_UPDATES, { changes: update_to_trace })
  end

  def step_price(step_name = nil, _options = {})
    step_name = self.step_name if step_name.blank?
    step_name = ConversionStep::DEFAULT_NAME if step_name.blank?
    conversion_step(step_name).step_prices.find do |x|
      x.affiliate_offer_id == affiliate_offer_id
    end
  end

  def check_beyond_referral_period?
    return false unless conv_step = conversion_step
    return false unless recorded_at?

    captured_time = captured_at || Time.now

    expiration = conv_step.days_to_expire.to_i
    expiration = 7 if conv_step.session_option == true

    (captured_time - recorded_at) > expiration.days.to_i
  end

  def mca?
    conversion_step&.conversion_manual?
  end

  def geo
    return if ip_address.blank?

    @geo ||= begin
      GEO_DB.lookup(ip_address)
    rescue StandardError
    end
  end

  def geo_location
    return if geo.blank?

    [geo.city&.name.presence, geo.subdivisions&.first&.name.presence, geo.country&.name.presence]
      .reject { |loc| loc.blank? || loc == '-' }
      .join(', ')
  end

  def affiliate_conv_type
    self[:affiliate_conv_type].presence || fetch_and_store_affiliate_conv_type
  end

  def fetch_and_store_affiliate_conv_type
    return unless conversions?

    conv_type = conversion_step&.affiliate_conv_type
    AffiliateStats::UpdateJob.perform_later(id, { affiliate_conv_type: conv_type }) if conv_type.present?
    conv_type
  end

  def device_info
    return if http_user_agent.blank?
    @device_info ||= DotOne::Track::DeviceInfo.new(user_agent: http_user_agent).to_data_for_tracking
  end

  def convert(options = {})
    self.conversions = 1 if conversions.blank?
    self.converted_at ||= Time.now unless options[:set_to_published] == true
  end

  # check for cap size on the affiliate offer
  # then mark whether the conversion exceed the cap or not.
  # if exceed, return true. Otherwise, return false.
  def reach_exceed_cap?
    return true if exceed_cap_on_campaign_level? || exceed_cap_on_offer_level?
    false
  end

  ##
  # Measure conversion exceeding the cap on campaign level
  def exceed_cap_on_campaign_level?
    # some requirement check
    return false if exceed_cap_check?
    return false if affiliate_offer&.cap_size.to_i == 0

    cap_instance = affiliate_offer
    conversion_so_far = cap_instance.conversion_so_far.to_i
    cap_size = cap_instance.cap_size

    OfferCaps::NotifyOnCapDepletedJob.perform_later(
      entity_type: 'AffiliateOffer',
      entity_id: affiliate_offer.id,
      cap_instance: cap_instance,
    )

    conversion_so_far > cap_size
  end

  ##
  # Measure conversion exceeding the cap on offer level
  def exceed_cap_on_offer_level?
    return false if exceed_cap_check?
    return false if offer&.offer_cap&.number.to_i == 0

    cap_instance = offer.offer_cap
    conversion_so_far = cap_instance.conversion_so_far.to_i
    cap_size = offer.offer_cap.number

    OfferCaps::NotifyOnCapDepletedJob.perform_later(
      entity_type: 'Offer',
      entity_id: offer.id,
      cap_instance: cap_instance,
    )

    conversion_so_far > cap_size
  end

  #################
  # SUPPRESSION
  #################

  def suppress
    return if order_suppressed? || inconclusive?

    return unless affiliate_offer.present? && affiliate_offer.pixel_suppress_rate.present?

    number = rand(1..1000)
    return unless number <= (affiliate_offer.pixel_suppress_rate * 10)

    self.status = Order.status_suppressed
  end

  ##############
  # PIXELS
  ##############

  # return html pixel based on this stat's affiliate offer
  def html_pixels
    pixels = []
    pixel_html = affiliate_offer&.conversion_pixel_html

    if pixel_html.present?
      pixel_html = format_pixel(pixel_html)
      pixels << pixel_html
      pixels << channel.conversion_pixel if channel_id.present?
    end

    pixels.compact
  end

  def fire_html!
    return if html_pixel_fired?
    return unless should_fire_confirmed_s2s?
    return if affiliate_offer.blank?

    flag(:html_pixel_fired, true)
    true
  end

  # return s2s pixel
  def s2s_pixels
    # obtain step level pixel
    pixels = if affiliate_offer.present? && conversion_step.present?
      affiliate_offer.step_pixels.where(conversion_step_id: conversion_step.id).first&.conversion_pixel_s2s
    end

    # obtain campaign level pixel
    pixels ||= affiliate_offer&.conversion_pixel_s2s

    # obtain any campaign level pixel
    # when specific campaign pixel is not determined, grab any available pixel for any campaign
    if cached_offer
      cached_offer.affiliate_offers.where(affiliate_id: affiliate_id).each do |ao|
        pixels ||= ao.conversion_pixel_s2s if ao.conversion_pixel_s2s.present?
      end
    end

    # obtain affiliate level pixel
    pixels ||= affiliate&.s2s_global_pixel

    [format_pixel(pixels)].compact
  end

  #################
  # Fire S2S
  #################

  def should_fire_confirmed_s2s?
    converted? && (considered_approved?(:network) || considered_rejected?)
  end

  def should_fire_pending_s2s?
    converted? && considered_pending?(:network)
  end

  def should_fire_2s?
    should_fire_pending_s2s? || should_fire_confirmed_s2s?
  end

  def queue_fire_s2s_routine
    return unless should_fire_2s?

    logger.warn "[AffiliateStat#queue_fire_s2s_routine] Queueing S2S for processing: stat_id = #{id}"

    AffiliateStats::FireS2sJob.perform_later([id])
    AffiliateStats::FireS2sJob.perform_later([id], confirmed: true) if should_fire_confirmed_s2s?
  end

  def queue_fire_s2s_confirmed_routine
    return unless should_fire_confirmed_s2s? && patched_previous_changes[:approval].present?

    logger.warn "[AffiliateStat#queue_fire_s2s_confirmed_routine] Queueing S2S for processing: stat_id = #{id}"

    AffiliateStats::FireS2sJob.perform_later([id], confirmed: true, fire_s2s_force: true)
  end

  def fire_s2s_routine(options = {})
    log_prefix = '[AffiliateStat#fire_s2s_routine]'
    arg_string = "options = #{options} stat_id = #{id}"

    forced = options[:fire_s2s_force] == true

    logger.warn "#{log_prefix} S2S Postback Routine: #{arg_string}"

    unless forced
      return if s2s_fired?
      return unless should_fire_2s?
    end

    # Direct S2S Pixel
    pixels = s2s_pixels || []

    pixels.compact.each do |px|
      uri_string = format_pixel(px)
      uri = URI(uri_string) rescue nil

      next unless uri_string.present? && uri.present?

      if uri.is_a?(URI::HTTPS)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
      else
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
      end

      Postback.create(
        postback_type: Postback.postback_type_outgoing,
        raw_request: uri.to_s,
        raw_response: response.body,
        affiliate_stat_id: id,
        recorded_at: Time.now,
      )

      flag(:s2s_fired, true)
      flag(:s2s_fired_amount, s2s_fired_amount + 1)
    end

    # Handle Captured Conversion API

    captured_conversion_api = cached_affiliate.try(:captured_conversion_api)

    return unless captured_conversion_api.present?

    logger.warn "#{log_prefix} S2S Captured Conversion API: #{arg_string} API ID: #{captured_conversion_api.id}"

    result = captured_conversion_api.post_conversion(self)

    logger.warn "#{log_prefix} S2S Captured Conversion API: #{arg_string} API Result: #{result}"

    return unless result.present?

    logger.warn "#{log_prefix} Creating Postback: #{arg_string}"
    postback = Postback.create(
      postback_type: Postback.postback_type_outgoing,
      raw_request: result[:request_body],
      raw_response: result[:response_body],
      affiliate_stat_id: id,
      recorded_at: Time.now,
    )
    if postback.errors.present?
      logger.warn "#{log_prefix} Postback Created Error: #{arg_string}. Postback Error: #{postback.errors.messages}"
    else
      logger.warn "#{log_prefix} Postback Created: #{arg_string}. Postback ID: #{postback.id}"
    end
    flag(:s2s_fired, true)
    flag(:s2s_fired_amount, s2s_fired_amount + 1)
  end

  def fire_confirmed_s2s_routine(options = {})
    return if cached_affiliate.blank?

    log_prefix = '[AffiliateStat#fire_confirmed_s2s_routine]'
    arg_string = "options = #{options} stat_id = #{id}"

    forced = options[:fire_s2s_force] == true

    logger.warn "#{log_prefix} Confirmed S2S Postback Routine: #{arg_string}"

    unless forced
      return if confirmed_s2s_fired?
      return unless should_fire_confirmed_s2s?
    end

    # Handle Confirmed Conversion API
    confirmed_conversion_api = cached_affiliate.confirmed_conversion_api

    return unless confirmed_conversion_api.present?

    logger.warn "#{log_prefix} S2S Confirmed Conversion API: #{arg_string} API ID: #{confirmed_conversion_api.id}"
    result = confirmed_conversion_api.post_conversion(self)
    logger.warn "#{log_prefix} S2S Confirmed Conversion API: #{arg_string} API Result: #{result}"

    return unless result.present?

    logger.warn "#{log_prefix} Creating Postback: #{arg_string}"
    postback = Postback.create(
      postback_type: Postback.postback_type_outgoing,
      raw_request: result[:request_body],
      raw_response: result[:response_body],
      affiliate_stat_id: id,
      recorded_at: Time.now,
    )
    if postback.errors.present?
      logger.warn "#{log_prefix} Postback Created Error: #{arg_string}. Postback Error: #{postback.errors.messages}"
    else
      logger.warn "#{log_prefix} Postback Created: #{arg_string}. Postback ID: #{postback.id}"
    end
    flag(:confirmed_s2s_fired, true)
    flag(:confirmed_s2s_fired_amount, confirmed_s2s_fired_amount + 1)
  end

  def format_pixel(str)
    return if str.blank?

    pixel = str.gsub(TOKEN_SUBID_1, subid_1.to_s)
    pixel = pixel.gsub(TOKEN_SUBID_2, subid_2.to_s)
    pixel = pixel.gsub(TOKEN_SUBID_3, subid_3.to_s)
    pixel = pixel.gsub(TOKEN_SUBID_4, subid_4.to_s)
    pixel = pixel.gsub(TOKEN_SUBID_5, subid_5.to_s)
    pixel = pixel.gsub(TOKEN_GAID, gaid.to_s)
    pixel = pixel.gsub(TOKEN_TID, id.to_s)
    pixel = format_content(pixel, :url)
    pixel = copy_order.format_content(pixel, :url) if copy_order.present?
    pixel
  end

  # format content to populate affiliate infos
  def format_content(content, type, _options = {})
    return if content.blank?

    content = content.gsub(/\r\n/, '') unless type == :email

    content.gsub(TOKEN_REGEX_TRANSACTION) do |_x|
      arg = Regexp.last_match(1)
      parameters = Regexp.last_match(2)
      # Cleanup any parentheses
      parameters = begin
        parameters.gsub(/[()]/, '').split(',')
      rescue StandardError
      end
      val = nil

      if arg.present? && respond_to?(arg)
        val = if parameters.present?
          send(arg, *parameters)
        else
          send(arg)
        end
        if type == :url
          val = CGI.escape(val.to_s)
        end

        val
      end
    end
  end

  def offer_variant_active_or_test?
    return false if offer_variant.blank?
    return true if test_run?

    offer_variant.considered_positive?
  end

  def test_run?
    AffiliateStat.test_run?(subid_1)
  end

  # This transaction may have many orders
  # where each order will call touch on this transaction, resulting
  # in many db calls to the same record doing the same thing.
  # We are utilizing kinesis mechanism to group similar ID and
  # update the record once
  def delayed_touch
    if Rails.env.production?
      to_kinesis(DotOne::Kinesis::TASK_DELAYED_TOUCH)
    else
      self.touch
    end
  end

  def touch_partitions
    if Rails.env.production?
      to_kinesis(DotOne::Kinesis::TASK_PARTITION_DELAYED_TOUCH)
    else
      PARTITIONS.each do |klass|
        klass.where(id: id).map(&:touch)
      end
    end
  end

  def mirror_to_redshift
    if Rails.env.production?
      to_kinesis(DotOne::Kinesis::TASK_REDSHIFT)
    else
      stat = Stat.find_or_initialize_by(id: id)
      stat.attributes = AffiliateStat.extract_attributes(self)
      stat.save

      mirror_to_partitions
    end

    true
  end

  def mirror_to_partitions
    return if Rails.env.production?

    PARTITIONS.each do |klass|
      next if klass == AffiliateStatCapturedAt && captured_at.blank?
      next if klass == AffiliateStatPublishedAt && published_at.blank?
      next if klass == AffiliateStatConvertedAt && converted_at.blank?

      stat = klass.find_or_initialize_by(id: id)
      stat.attributes = AffiliateStat.extract_attributes(self)
      stat.save
    end
  end

  def delete_from_other_partitions
    count = 1
    PARTITIONS.each do |klass|
      delete_sql = "DELETE FROM #{klass.table_name} WHERE id = ('#{id}')"
      klass.connection.execute(delete_sql)
    rescue StandardError
      if count <= 3 # Retry three times with delay
        puts "Deleting ID #{id} #{count} time(s)"
        sleep(15 * count)
        retry
        count += 1
      else
        super
      end
    end
  end

  def conversion_step_snapshots
    return if conversion_steps.blank?

    conversion_steps.keys.map do |key|
      snapshot = conversion_steps[key].with_indifferent_access
      current = conversion_step(key) if snapshot[:true_conv_type].blank? || snapshot[:affiliate_conv_type].blank? || snapshot[:currency_code].blank?

      if current
        snapshot[:true_conv_type] ||= current.true_conv_type
        snapshot[:affiliate_conv_type] ||= current.affiliate_conv_type
        snapshot[:currency_code] ||= current.original_currency
      end

      if ConversionStep.is_share_rate?(:true, snapshot[:true_conv_type]) &&
        ConversionStep.is_share_rate?(:affiliate, snapshot[:affiliate_conv_type]) &&
        snapshot[:affiliate_share].to_f > snapshot[:true_share].to_f &&
        (current ||= conversion_step(key))
        snapshot[:true_share] = current.true_share
        snapshot[:affiliate_share] = current.affiliate_share
      end

      if ConversionStep.is_flat_rate?(:true, snapshot[:true_conv_type]) &&
        ConversionStep.is_flat_rate?(:affiliate, snapshot[:affiliate_conv_type]) &&
        snapshot[:affiliate_pay].to_f > snapshot[:true_pay].to_f &&
        (current ||= conversion_step(key))
        snapshot[:true_pay] = current.true_pay
        snapshot[:affiliate_pay] = current.affiliate_pay
      end

      snapshot.merge(name: key)
    end
  end

  def related_stat_ids
    [original.id, original.subid_1, original.copy_stats.ids].flatten.select do |id|
      AffiliateStat.valid_id?(id)
    end
  end

  private

  def generate_id
    self.id = DotOne::Utils.generate_token if id.blank?
  end

  def set_defaults
    self.original_currency ||= Currency.platform_code
  end

  ##
  # Assign the forex to the attribute without committing it
  # to the database
  # Parameters:
  #   force - if true, it will refresh the forex info already stored
  #     in the database. If false, it will keep the stored version
  def set_forex(force = false)
    if force == false && self[:forex].present?
      false
    else
      # Get it from its sibling if any
      current_rates = sibling_forex_rates

      # Store USD as standard currency since conversion rate
      # to other currencies is more precise (less decimal points)
      current_rates = Currency.converter.generate_rate_map(Currency.default_code) if current_rates.blank?

      raise 'Forex rates does not exist' if current_rates.blank?

      self.forex = current_rates
    end
  end

  def adjust_values
    generate_id

    self.network_id = offer&.network_id if network_id.blank? || network_id == 0
    self.offer_variant_id = offer&.default_offer_variant&.id if offer_variant_id.blank? || offer_variant_id == 0

    if conversions?
      set_forex

      self.order_number ||= copy_order&.order_number

      if approval.blank? && status.present? || status_changed?
        self.approval = AffiliateStat.decide_approval(status)
      end

      self.captured_at ||= published_at || converted_at || Time.now

      if AffiliateStat.approvals_considered_rejected.include?(approval_was) && considered_approved? && cached_offer&.single?
        self.published_at = Time.now
        self.converted_at = Time.now
      elsif pending? || inconclusive?
        self.published_at = nil
        self.converted_at = nil
      elsif published?
        self.published_at ||= converted_at || Time.now
        self.converted_at = nil
      elsif approved? || adjusted? || rejected? || full_return?
        self.published_at ||= converted_at || Time.now
        self.converted_at ||= Time.now
      end

      if approval_was == AffiliateStat.approval_pending && AffiliateStat.approvals_considered_approved.include?(approval)
        [:published_at, :converted_at].each do |column|
          value = send(column)
          if value.present? && send("#{column}_changed?") && !DotOne::Utils.date_convertable?(value)
            self.send("#{column}=", DotOne::Utils.earliest_conversion_date)
          end
        end
      end

      current_valid_status = AffiliateStat.approval_status_map[self.approval] || []

      unless current_valid_status.include?(status)
        order_status = copy_order&.status
        self.status = current_valid_status.include?(order_status) ? order_status : current_valid_status.first
      end

      self.exceed_cap_check = true if order_exceed_cap?
    else
      self.captured_at = nil
      self.published_at = nil
      self.converted_at = nil
    end
  end

  def update_order_related
    if copy_order.present? && copy_order[:forex].blank?
      copy_order.update_columns(forex: forex, updated_at: Time.now)
    end

    if !pending? && missing_order&.confirming?
      missing_order.update_columns(
        status: MissingOrder.status_approved,
        status_summary: MissingOrder.status_summary_order_added,
        updated_at: Time.now
      )
    end
  end

  def delete_from_redshift
    count = 1
    begin
      delete_sql = "DELETE FROM stats WHERE id = ('#{id}')"
      Stat.exec_sql(delete_sql)
    rescue StandardError
      if count <= 3 # Retry three times with delay
        puts "Deleting STAT ID #{id} #{count} time(s)"
        sleep(15 * count)
        retry
        count += 1
      else
        super
      end
    end
  end
end
