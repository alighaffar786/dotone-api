class Offer < DatabaseRecords::PrimaryRecord
  include AffHashable
  include AffiliateLoggable
  include AffiliateTaggable
  include ConstantProcessor
  include DateRangeable
  include DynamicTranslatable
  include Forexable
  include HasKeywords
  include LocalTimeZone
  include ModelCacheable
  include NameHelper
  include Scopeable
  include Snippetable
  include StaticTranslatable
  include Traceable
  include DotOne::I18n
  include OfferHelpers::EsSearch
  include Relations::AffiliateStatAssociated
  include Relations::HasCategoryGroups
  include Relations::HasClientApis
  include Relations::NetworkAssociated
  include Tokens::Tokenable

  TYPES = ['NetworkOffer', 'EventOffer'].freeze
  APPROVAL_METHODS = ['As It Occurs', 'Payment Received'].freeze
  CONVERSION_POINTS = ['Single', 'Multi'].freeze

  has_many_affiliate_stats
  has_many :bot_stats, inverse_of: :offer
  has_many :ads, inverse_of: :offer, dependent: :nullify
  has_many :ad_slot_offers, inverse_of: :offer, dependent: :destroy
  has_many :ad_slots, through: :ad_slot_offers
  has_many :offer_variants, -> { order(is_default: :desc) }, inverse_of: :offer, dependent: :destroy
  has_many :email_templates, as: :owner, inverse_of: :owner, dependent: :destroy

  has_many :active_offer_variants, -> { where(status: OfferVariant.status_considered_active) }, class_name: 'OfferVariant', inverse_of: :offer

  has_many :affiliate_offers, inverse_of: :offer, dependent: :destroy
  has_many :active_affiliate_offers, -> { active }, class_name: 'AffiliateOffer', inverse_of: :offer
  has_many :affiliates, through: :affiliate_offers

  has_many :active_affiliates, -> { active }, through: :active_affiliate_offers, class_name: 'Affiliate', source: :affiliate

  has_many :image_creatives, through: :offer_variants
  has_many :active_image_creatives, -> { active }, class_name: 'ImageCreative', through: :active_offer_variants, source: :image_creatives

  has_many :text_creatives, through: :offer_variants
  has_many :active_text_creatives, -> { active }, class_name: 'TextCreative', through: :active_offer_variants, source: :text_creatives

  has_many :offer_countries, inverse_of: :offer, dependent: :destroy
  has_many :countries, through: :offer_countries, inverse_of: :offers
  has_many :allowed_countries, -> { order(name: :asc) }, through: :offer_countries, source: :country
  has_many :offer_categories, inverse_of: :offer, dependent: :destroy
  has_many :categories, through: :offer_categories
  has_many_category_groups through: :categories
  has_many :stats, inverse_of: :offer
  has_many :conversion_steps, inverse_of: :offer, dependent: :destroy
  has_many :ordered_conversion_steps, -> { ordered }, class_name: 'ConversionStep', inverse_of: :offer
  has_many :step_prices, through: :conversion_steps
  has_many :pay_schedules, through: :conversion_steps
  has_many :orders, inverse_of: :offer, dependent: :nullify
  has_many :child_pixels, inverse_of: :offer, dependent: :destroy
  has_many :product_categories, inverse_of: :offer, dependent: :destroy
  has_many :media_restrictions, through: :owner_has_tags
  has_many :top_traffic_sources, through: :owner_has_tags
  has_many :group_tags, through: :owner_has_tags
  has_many :top_network_offer_categories, through: :owner_has_tags, source: :top_network_offer
  has_many :offer_stats, inverse_of: :offer, dependent: :destroy
  has_many :offer_stats_last_month, -> { where(date: 30.days.ago.to_date..Time.now.utc.to_date) }, class_name: 'OfferStat'

  has_many :missing_orders, inverse_of: :offer, dependent: :destroy
  has_many :confirming_missing_orders, -> { where(status: MissingOrder.status_confirming) }, class_name: 'MissingOrder', inverse_of: :offer
  has_many :mkt_sites, inverse_of: :offer, dependent: :destroy
  has_many :vtm_channels, inverse_of: :offer, dependent: :destroy

  has_many :campaigns, through: :offer_variants
  has_many :offer_conversion_pixels, inverse_of: :offer, dependent: :destroy
  has_many :products, inverse_of: :offer, dependent: :destroy
  has_many :shopify_setups, inverse_of: :offer, dependent: :nullify
  has_many :easy_store_setups, inverse_of: :offer, dependent: :nullify
  has_many :newsletters, foreign_key: :offer_list, inverse_of: :offer, dependent: :nullify

  has_one :mkt_site, inverse_of: :offer, dependent: :nullify
  has_one :default_offer_variant, -> { default }, class_name: 'OfferVariant'
  has_one :offer_cap, through: :default_offer_variant
  has_one :default_conversion_step, -> { ordered }, class_name: 'ConversionStep', inverse_of: :offer
  has_one :easy_store_setup, inverse_of: :offer, dependent: :nullify

  # 300x300
  has_one :brand_image, -> { brand_image }, class_name: 'Image', as: :owner, inverse_of: :owner, dependent: :destroy, autosave: true

  # 88x31
  has_one :brand_image_small, -> { brand_image_small }, class_name: 'Image', as: :owner,
    inverse_of: :owner, dependent: :destroy, autosave: true

  # 120x60
  has_one :brand_image_medium, -> { brand_image_medium }, class_name: 'Image', as: :owner,
    inverse_of: :owner, dependent: :destroy, autosave: true

  # 300x125
  has_one :brand_image_large, -> { brand_image_large }, class_name: 'Image', as: :owner,
    inverse_of: :owner, dependent: :destroy, autosave: true

  has_one :product_api, -> { product_api }, class_name: 'ClientApi', as: :owner,
    inverse_of: :owner, dependent: :destroy

  has_one :js_conversion_pixel, -> { javascript }, class_name: 'OfferConversionPixel', inverse_of: :offer

  has_and_belongs_to_many :terms, join_table: :offer_terms, inverse_of: :event_offers

  accepts_nested_attributes_for :default_offer_variant

  validates :name, presence: true
  validates :earning_meter, presence: true

  before_validation :set_defaults
  before_save :adjust_values
  after_save :populate_package_name, :set_destination_url_to_keywords, :reset_notification_status

  serialize :track_device

  set_token_prefix :offer
  set_local_time_attributes :published_date
  set_forexable_attributes :custom_epc
  set_static_translatable_attributes(:cap_type, cap_type: 'predefined.models.offer_cap.cap_type')
  set_dynamic_translatable_attributes(
    name: :plain,
    brand_background: :html,
    product_description: :html,
    other_info: :html,
    short_description: :plain,
    target_audience: :plain,
    offer_name: :plain,
    suggested_media: :plain,
    approval_message: :html,
    custom_approval_message: :plain,
    manager_insight: :plain,
  )

  set_predefined_flag_attributes :offer_name, :custom_approval_message, :linkshare_ftp_mid_sid, :linkshare_ftp_available_locales,
    :line_shop_id, :line_authkey, :line_is_new_member_step_name
  set_predefined_flag_attributes :will_notify_24_hour_paused, :will_notify_48_hour_paused, :notified_24_hour_pause,
    :notified_48_hour_pause, :skip_order_api, :use_direct_advertiser_url, :do_not_reformat_deeplink_url,
    :placement_needed, :cap_depleted, :line_use_click_time, type: :boolean
  set_predefined_flag_attributes :deeplink_modifier, type: :json
  set_instance_cache_methods :default_offer_variant, :default_conversion_step, :ordered_conversion_steps, :active_offer_variants,
    :countries, :category_groups, :aff_hash, :brand_image, :brand_image_small, :brand_image_medium, :brand_image_large

  define_constant_methods(TYPES, :type)
  define_constant_methods(APPROVAL_METHODS, :approval_method)
  define_constant_methods(CONVERSION_POINTS, :conversion_point)

  scope_by_country :cache_country_ids
  scope_by_approval_method

  scope :recent, -> { order(created_at: :desc) }
  scope :recently_published, -> { order(published_date: :desc) }
  scope :active, -> { joins(:default_offer_variant).merge(OfferVariant.active) }
  scope :active_public, -> { joins(:default_offer_variant).merge(OfferVariant.active_public) }
  scope :non_suspended, -> { joins(:default_offer_variant).merge(OfferVariant.not_suspended) }
  scope :considered_active_public, -> { joins(:default_offer_variant).merge(OfferVariant.considered_active_public)}

  scope :with_media_restrictions, -> (*args) {
    if args.present? && args[0].present? && args[0].is_a?(Array)
      conditions = []
      args[0].each do |_x|
        conditions << 'FIND_IN_SET(?, traffic_restriction_ids) > 0'
      end
      query = ["(#{conditions.join(' OR ')})"]
      where(query + args[0])
    end
  }

  scope :without_media_restrictions, -> (*args) {
    if args.present? && args[0].present? && args[0].is_a?(Array)
      conditions = []
      args[0].each do |_x|
        conditions << 'FIND_IN_SET(?, traffic_restriction_ids) = 0'
      end
      query = ["(#{conditions.join(' OR ')})"]
      where(query + args[0])
    end
  }

  scope :with_offer_variant_statuses, -> (*args) {
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0].join("','")
      where("offer_variants.status IN ('#{values}') AND offer_variants.is_default = 1")
    end
  }

  scope :with_categories, -> (*args) {
    where('FIND_IN_SET(?, cache_category_ids) <> 0', args[0]) if args[0].present?
  }

  scope :with_deep_link, -> (*args) {
    if args.present? && (BooleanHelper.truthy?(args[0]) || BooleanHelper.falsy?(args[0]))
      if BooleanHelper.truthy?(args[0])
        where('offer_variants.can_config_url = true')
      elsif BooleanHelper.falsy?(args[0])
        where('offer_variants.can_config_url IS NULL or offer_variants.can_config_url = false')
      end
    end
  }

  scope :auto_approvable_offers, -> {
    considered_active_public
      .where(need_approval: false)
      .where(offer_variants: { can_config_url: true })
  }

  delegate :status_previously_changed?, to: :default_offer_variant

  [nil, :small, :medium, :large].each do |variant|
    method_name = [:brand_image, variant].compact.join('_')

    define_method("#{method_name}_url=") do |value|
      brand_image = send(method_name).presence

      if value.present?
        brand_image ||= send("build_#{method_name}")
        brand_image.cdn_url = value
      else
        brand_image.mark_for_destruction if brand_image&.persisted?
      end
    end

    define_method("#{method_name}_url") do
      send("cached_#{method_name}")&.cdn_url
    end
  end

  def self.bulk_touch(id_collection)
    return if id_collection.blank?

    id_collection.uniq.each_slice(500) do |group_ids|
      Offer.where(id: group_ids).update_all(updated_at: Time.now)
    end
  end

  def self.any_advertiser_prospects?
    AffiliateTag.get_advertiser_prospect.offers.any?
  end

  def self.any_affiliate_prospects?
    AffiliateTag.get_affiliate_prospect.offers.any?
  end

  def affiliate_prospect?
    affiliate_tags.affiliate_prospect.any?
  end

  def advertiser_prospect?
    affiliate_tags.advertiser_prospect.any?
  end

  # manual conversion approval
  def mca?
    default_conversion_step&.conversion_manual?
  end

  def status
    cached_default_offer_variant&.status
  end

  def active?
    !!cached_default_offer_variant&.active?
  end

  def active_public?
    !!cached_default_offer_variant&.active_public?
  end

  def active_affiliate_offer_for(affiliate, catch_any: false)
    affiliate_offer = AffiliateOffer.active_best_match(affiliate, self)
    affiliate_offer ||= AffiliateOffer.best_match_or_create(Affiliate.catch_all, self, true) if catch_any
    affiliate_offer if affiliate_offer&.active?
  end

  def has_ad_link?
    !need_approval? && deeplinkable? && default_offer_variant.active_public?
  end

  def has_native_ads?
    text_creatives
      .active
      .publishable
      .joins(:offer_variants)
      .where(offer_variants: { status: OfferVariant.status_considered_active })
      .any?
  end

  def has_banners?
    image_creatives
      .active
      .publicly
      .publishable
      .any?
  end

  def has_data_feed?
    !!product_api&.active?
  end

  def approved_time_for_affiliate(affiliate)
    if payment_received? || affiliate.approval_method == Offer.approval_method_payment_received
      'After Advertiser Payment'
    else
      approved_time
    end
  end

  def cap_percentage_remaining
    return if offer_cap.blank? || offer_cap.number.blank?

    remaining = begin
      100 - ((offer_cap.conversion_so_far.to_f / offer_cap.number.to_f) * 100)
    rescue StandardError
    end
    remaining.present? ? "#{remaining.to_i}%" : nil
  end

  def cap_percentage_used
    return if offer_cap.blank? || offer_cap.number.blank?

    cap_used = begin
      (offer_cap.conversion_so_far.to_f / offer_cap.number.to_f) * 100
    rescue StandardError
    end
    cap_used.present? ? "#{cap_used.to_i}%" : nil
  end

  def cap_type
    offer_cap&.cap_type
  end

  def has_cap?
    offer_cap&.number.present?
  end

  # Method to return total allocated caps
  def cap_allocated
    @cap_allocated ||= affiliate_offers.sum(:cap_size)
  end

  ##
  # Eligible recipients for cap notification
  def cap_notification_recipients
    recipients = []

    # Collect affiliates as recipients
    affiliates = active_affiliates
    recipients << affiliates

    # Collect affiliate's contact lists as recipients
    recipients << affiliates.map(&:contact_lists)

    # Collect the affiliate managers as recipients
    affiliate_user_ids = AffiliateAssignment.where(affiliate_id: affiliates.map(&:id))
      .map(&:affiliate_user_id)
    recipients << AffiliateUser.active.where(id: affiliate_user_ids)

    # Clean up the recipient lists
    recipients.flatten.uniq { |x| x.email }
  end

  def notify_on_cap_depleted!(cap_instance, lower_threshold, upper_threshold)
    cap_notifier = DotOne::Services::CapNotifier.new(instance_to_notify: self, notification_type: :offer)

    DotOne::Services::CapChecker.new({
      lower_threshold: lower_threshold,
      upper_threshold: upper_threshold,
      cap_instance: cap_instance,
      cap_size: cap_instance.number,
      cap_notified_at: cap_instance.cap_notified_at,
    }).check do |checker|
      cap_notifier.cap_ratio_used = checker.closest_threshold_from_ratio

      checker.when_depleting do |_cap_instance|
        cap_notifier.send_depleting_email(cap_notification_recipients)
      end

      checker.when_depleted do |_cap_instance|
        cap_notifier.send_depleted_email(cap_notification_recipients)
        flag(:cap_depleted, true)
      end

      checker.when_reset do |cap_instance|
        cap_instance.update(cap_notified_at: nil)
      end
    end
  end

  def creatives
    creatives = offer_variants.map do |offer_variant|
      offer_variant.image_creatives + offer_variant.text_creatives
    end
    creatives.flatten.compact.uniq
    # image_creatives = self.offer_variants.map(&:image_creatives)
    # image_creatives.flatten.compact.uniq.sort{ |x,y| x.size <=> y.size }
  end

  # returns default creative based on the default offer variant and the given size.
  def default_creative(type, size = {}, options = {})
    if type == 'ImageCreative'
      if options['data-internal']
        cached_default_offer_variant.image_creatives.active.internally.with_locales(options[:locale]).find_by_size(size) ||
          cached_default_offer_variant.image_creatives.active.with_locales(options[:locale]).find_by_size(size)
      else
        cached_default_offer_variant.image_creatives.active.with_locales(options[:locale]).find_by_size(size)
      end

    else
      cached_default_offer_variant.text_creatives.with_locales(options[:locale]).first
    end
  end

  def sized_brand_image(size)
    if size == :small
      brand_image_small
    elsif size == :medium
      brand_image_medium
    elsif size == :large
      brand_image_large
    elsif size == :default
      brand_image
    end
  end

  # Determine the conversion step
  def conversion_step(step_name = nil)
    return if step_name.blank?

    cached_ordered_conversion_steps.find { |x| DotOne::Utils.str_match?(x.name, step_name) }
  end

  def currency_for(type)
    type = type.to_sym
    if type == :payout
      if default_conversion_step.blank?
        Currency.current
      else
        default_conversion_step.true_currency
      end
    else
      Currency.current
    end
  end

  # To handle dynamic info calls
  def method_missing(method, *args)
    if method.to_s =~ /^kvp_/
      key = method.to_s.gsub(/^kvp_/, '')
      val = nil

      kvp_tag = args && args[0]
      val = flag("#{key}_tag_#{kvp_tag}") if kvp_tag.present?

      val = flag(key) if val.blank?

      # split test data if present
      val = val.to_s.split(TOKEN_SPLIT)
      val = begin
        val.sample.strip
      rescue StandardError
      end

      return val
    end

    super
  end

  ## EMAIL TEMPLATE STUFF ##

  def email_template_with_type(email_type)
    email_templates.find_by(email_type: email_type)
  end

  # Erwin at April 21, 2015:
  # check certain email template to see if it is active and ready to use.
  # It would be great to be able to have this inside the Mailer class. But,
  # Rails 3.0.x cannot have condition to cancel mail delivery.
  # Read this: http://stackoverflow.com/questions/6550809/rails-3-how-to-abort-delivery-method-in-actionmailer
  def email_template_available?(email_type)
    email_template = email_template_with_type(email_type)
    template_ready = false
    if email_template.present? &&
        email_template.active? &&
        email_template.subject.present? &&
        email_template.content.present? &&
        email_template.sender.present? &&
        email_template.recipient.present?
      template_ready = true
    end
    template_ready
  end

  ## END EMAIL TEMPLATE STUFF ##

  def conversion_point
    self[:conversion_point].presence || Offer.conversion_point_single
  end

  def multi_conversion_point?
    multi?
  end

  def single_conversion_point?
    !multi_conversion_point?
  end

  def best_variant_for_current_device_type(device_type, fallback_offer_variant = nil)
    return if device_type.blank?
    return if cached_active_offer_variants.blank?

    # When fallback offer variant is good enough, use that.
    # There is no need to find for better options.
    if fallback_offer_variant.active?
      available_tags = fallback_offer_variant.cached_affiliate_tags.map(&:name)
      return fallback_offer_variant if available_tags.include?(device_type)
    end

    variant = cached_active_offer_variants.find { |v| v.cached_affiliate_tags.map(&:name).include?(device_type) }
    variant ||= fallback_offer_variant if fallback_offer_variant&.active?
    variant
  end

  def similar_offers
    return unless category_groups.any?

    Offer.joins(:category_groups, :offer_variants)
      .where(type: type)
      .where(category_groups: { id: category_groups.select(:id) })
      .where.not(id: id)
      .merge(OfferVariant.active_public)
      .distinct
  end

  def deeplinkable?
    !!cached_default_offer_variant&.can_config_url?
  end

  def detail_views_last_month
    @detail_views_last_month ||= begin
      range = 30.days.ago.to_date..Time.now.utc.to_date
      view_counts_map = offer_stats_last_month
        .group_by(&:date)
        .map { |date, stat| [date, stat.sum(&:detail_view_count)] }
        .to_h
      range.map { |date| view_counts_map[date].to_i }
    end
  end

  # To satisfy downloads when requested. We only
  # show the total of this view count
  def detail_view_count
    @detail_view_count ||= detail_views_last_month.sum
  end

  def request_count
    self[:request_count] || affiliate_offers.active.count
  end

  def in_adult_category?
    category_groups.adult.any?
  end

  def record_pixel_installed!(pixel_type)
    return if pixel_type.blank?

    pixel = offer_conversion_pixels.find_or_initialize_by(pixel_type: pixel_type)
    pixel.new_record? ? pixel.save! : pixel.touch
  end

  def destination_hostname
    DotOne::Utils::Url.host_name_without_www(destination_url)
  end

  def has_product_api?
    product_api.present?
  end

  def whitelisted_destination_urls
    self[:whitelisted_destination_urls].presence || []
  end

  def normalized_whitelisted_destination_urls
    whitelisted_destination_urls
      .map { |url| DotOne::Utils::Url.parse(url, flexible: true).to_s }
      .reject(&:blank?)
      .uniq
  end

  private

  def set_defaults
    self.conversion_point ||= Offer.conversion_point_single
    self.earning_meter = 0 if earning_meter.blank?
  end

  def adjust_values
    self.whitelisted_destination_urls = normalized_whitelisted_destination_urls
    self.country_names = countries.sort_by(&:name).map(&:name).join(',')
    self.category_names = categories.sort_by(&:name).map(&:name).join(',')
    self.cache_category_ids = category_ids.sort.join(',')
    self.traffic_restriction_ids = media_restriction_ids.sort.join(',')
    self.cache_country_ids = country_ids.sort.join(',')

    set_conversion_types
  end

  def set_conversion_types
    conv_types = conversion_steps.map(&:true_conv_type).uniq
    # store true conv type in offer.
    self.true_conv_type = if conv_types.size > 1
      ConversionStep::CONV_TYPE_CPA
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPS)
      ConversionStep::CONV_TYPE_CPS
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPI)
      ConversionStep::CONV_TYPE_CPI
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPL)
      ConversionStep::CONV_TYPE_CPL
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPE)
      ConversionStep::CONV_TYPE_CPE
    else
      ConversionStep::CONV_TYPE_CPL
    end

    # store affiliate conv type in offer
    conv_types = conversion_steps.map(&:affiliate_conv_type).uniq

    self.affiliate_conv_type = if conv_types.size > 1
      ConversionStep::CONV_TYPE_CPA
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPS)
      ConversionStep::CONV_TYPE_CPS
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPI)
      ConversionStep::CONV_TYPE_CPI
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPL)
      ConversionStep::CONV_TYPE_CPL
    elsif conv_types.include?(ConversionStep::CONV_TYPE_CPE)
      ConversionStep::CONV_TYPE_CPE
    else
      ConversionStep::CONV_TYPE_CPL
    end
  end

  def reset_notification_status
    return unless expired_at_previously_changed?

    self.notified_24_hour_pause = false
    self.notified_48_hour_pause = false
  end

  def populate_package_name
    # package name for Android
    if destination_url.present? && destination_url.include?('play.google.com/store/apps')
      u = URI(destination_url) rescue nil
      if u.present?
        parsed = begin
          CGI.parse(u.query)
        rescue StandardError
        end
        begin
          Offer.where(id: id).update_all(package_name: parsed['id'].first)
        rescue StandardError
        end
      end

      # package name for iOS
    elsif destination_url.present? && destination_url.include?('itunes.apple.com')
      # grab appID
      u = URI(destination_url) rescue nil
      app_id = begin
        u.path.split('/').last.gsub('id', '')
      rescue StandardError
      end
      if app_id.present?
        # grab json information from iTunes API
        response = begin
          Net::HTTP.get_response('itunes.apple.com', "/lookup?id=#{app_id}")
        rescue StandardError
        end
        json_body = begin
          JSON.parse(response.body)
        rescue StandardError
        end
        if json_body.present?
          begin
            Offer.where(id: id).update_all(package_name: json_body.to_hash.results.first.bundleId)
          rescue StandardError
          end
        end
      end
    end
  end

  def set_destination_url_to_keywords
    return if destination_url_was == destination_url

    save_url_as_keywords(destination_url_was, destination_url)

    if network_id.present? && network.respond_to?(:save_url_as_keywords)
      network.save_url_as_keywords(
        destination_url_was,
        destination_url,
      )
    end
  end
end
