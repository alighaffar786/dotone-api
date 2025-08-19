require 'zip'

class NetworkOffer < Offer
  include Comparable
  include LocalTimeZone
  include NetworkOfferHelpers::Downloadable
  include NetworkOfferHelpers::Query

  index_name 'offers'
  document_type 'offers'

  APPROVED_TIMES = [
    'N/A',
    'Instant',
    'Within N Days',
    'Within N Minutes',
  ].freeze

  TRACKING_TYPES = [
    'Real Time',
    'Daily Update',
    'Weekly Update',
    'Monthly Update',
  ].freeze

  ATTRIBUTION_TYPES = [
    'First Click',
    'Last Click',
    'Both Click',
  ].freeze

  TRACK_DEVICES = [
    'Desktop',
    'Mobile Web',
    'iOS',
    'Android',
  ].freeze

  define_constant_methods APPROVED_TIMES, :approved_time
  define_constant_methods TRACKING_TYPES, :tracking_type
  define_constant_methods ATTRIBUTION_TYPES, :attribution_type
  define_constant_methods TRACK_DEVICES, :track_device

  validates :short_description, length: { maximum: 80 }
  validates :approved_time, inclusion: { in: approved_times, allow_blank: true }
  validates :name, uniqueness: { case_sensitive: true, scope: :type }

  before_save :adjust_values

  set_local_time_attributes :expired_at, :published_date
  trace_has_many_includes :offer_variants, :conversion_steps, :image_creatives, :text_creatives, :offer_cap,
    :pay_schedules

  # Frequent system background updates does not need to be logged.
  trace_ignorable :sparkline_data, :epc
  set_predefined_flag_attributes :min_conv_rate, :max_conv_rate, :min_epc, :max_epc, type: :float

  amoeba do
    enable
    propagate :strict
    nullify :published_date
    prepend name: "Copy #{Time.now.to_i} of "

    include_association [
      :offer_variants,
      :conversion_steps,
      :offer_countries,
      :offer_categories,
      :owner_has_tags,
      :email_templates,
    ]

    customize(-> (_, copy) {
      copy.offer_variants.each do |variant|
        next unless variant.is_default?

        variant.status = OfferVariant.status_paused
      end
    })
  end

  def self.cached_for_ad_links
    DotOne::Cache.fetch("OFFER-FOR-ADLINK-#{Offer.cached_max_updated_at}") do
      NetworkOffer.auto_approvable_offers
        .pluck(:destination_url, :whitelisted_destination_urls, :id)
        .flat_map do |offer|
          url, whitelisted, id = offer
          urls = [url, whitelisted].flatten.compact_blank

          urls.map { |d| [DotOne::Utils::Url.host_name_without_www(d), id] }
        end
        .to_h
    end
  end

  def active_image_creatives(options = {})
    to_return = cached_active_offer_variants.flat_map(&:cached_image_creatives)
    to_return = to_return.select(&:active?)
    to_return = to_return.select(&:presentable_to_affiliate?) if options[:for_affiliates] == true
    to_return.compact.uniq.sort { |x, y| x.size.to_s <=> y.size.to_s }
  end

  def active_text_creatives(options = {})
    to_return = cached_active_offer_variants.flat_map(&:cached_text_creatives)
    to_return = to_return.select(&:active?) if [options[:for_affiliates], options[:for_network]].include?(true)
    to_return.compact.uniq
  end

  def active_public?
    !!cached_default_offer_variant&.active_public?
  end

  def similar_offers
    NetworkOffer
      .joins(:category_groups, :offer_variants)
      .where(category_groups: { id: category_groups.select(:id) })
      .where.not(id: id)
      .merge(OfferVariant.active_public)
      .distinct
  end

  def payout_details(currency_code = Currency.platform_code)
    cached_ordered_conversion_steps.map do |cs|
      cs.payout_details(currency_code)
    end
  end

  def commission_details(affiliate: nil, currency_code: Currency.platform_code)
    return [] if default_offer_variant.suspended?

    cs_map = ordered_conversion_steps
      .preload(:active_pay_schedule, :true_currency, :label_translations)
      .map do |cs|
        next unless commission = cs.commission_details(currency_code)

        [cs.t_label_safe, commission]
      end
      .compact
      .to_h

    # When affiliate is known, only show price for that affiliate
    affiliate_offers = if affiliate.present?
      affiliate.affiliate_offers.where(offer_id: id)
    else
      self.affiliate_offers.active
    end

    if affiliate_offers.any?
      sp_map = StepPrice
        .where(affiliate_offer_id: affiliate_offers.select(:id))
        .preload(:active_pay_schedule, conversion_step: :true_currency)
        .map do |sp|
          next unless commission = sp.commission_details(currency_code)

          [sp.conversion_step.t_label_safe, commission]
        end
        .compact
        .to_h
    end

    cs_map
      .merge(sp_map || {})
      .map { |label, value| value.merge(label: label, mixed_affiliate_pay: mixed_affiliate_pay) }
  end

  def calculate_affiliate_pay_range(user, currency_code = Currency.platform_code)
    value = NetworkOffer.where(id: id).agg_affiliate_pay(user, currency_code)&.first
    DotOne::Utils.to_number_range(value.min_affiliate_pay, value.max_affiliate_pay)
  end

  def calculate_affiliate_share_range(user)
    value = NetworkOffer.where(id: id).agg_affiliate_pay(user, Currency.platform_code)&.first
    DotOne::Utils.to_number_range(value.min_affiliate_share, value.max_affiliate_share)
  end

  def calculate_true_pay_range(currency_code = Currency.platform_code)
    value = NetworkOffer.where(id: id).agg_true_pay(currency_code)&.first
    DotOne::Utils.to_number_range(value.min_true_pay, value.max_true_pay)
  end

  def calculate_true_share_range
    value = NetworkOffer.where(id: id).agg_true_pay(Currency.platform_code)&.first
    DotOne::Utils.to_number_range(value.min_true_share, value.max_true_share)
  end

  def valid_host?(target)
    return false if target.blank?

    target_host = DotOne::Utils::Url.host_name(target)
    return false if target_host.blank?

    urls = [destination_url, *offer_variants.map(&:destination_url)]
      .map { |url| DotOne::Utils::Url.host_name(url) }
      .reject(&:blank?)
      .uniq

    urls.any? { |url| url == target_host }
  end

  def destination_urls
    [destination_url, *whitelisted_destination_urls].compact_blank.uniq.map(&:strip)
  end

  def whitelisted?
    whitelisted_destination_urls.compact_blank.present?
  end

  def destination_match?(url)
    destination_urls.any? do |d_url|
      whitelisted? ? DotOne::Utils::Url.host_match?(d_url, url) : DotOne::Utils::Url.domain_match?(d_url, url)
    end
  end

  private

  def adjust_values
    super

    if no_expiration?
      self.expired_at = nil
      self.will_notify_24_hour_paused = 0
      self.will_notify_48_hour_paused = 0
    end
  end
end
