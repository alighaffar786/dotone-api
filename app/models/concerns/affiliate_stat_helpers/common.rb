##
# Collection of methods shared among affiliate stat
# models. (AffiliateStat, AffiliateStatCapturedAt, etc.)
module AffiliateStatHelpers::Common
  extend ActiveSupport::Concern

  include AddressMaskable
  include BooleanHelper
  include ConstantProcessor
  include DateRangeable
  include Forexable
  include LocalTimeZone
  include Scopeable
  include AffiliateStatHelpers::Downloadable
  include DotOne::I18n
  include Relations::AffiliateAssociated
  include Relations::CampaignAssociated
  include Relations::ChannelAssociated
  include Relations::LanguageAssociated
  include Relations::NetworkAssociated
  include Relations::OfferAssociated
  include Relations::OfferVariantAssociated

  APPROVALS = [
    'Approved',     # Affiliate gets credit. Advertiser has to pay.
    'Pending',      # Waiting for Advertiser's decision.
    'Rejected',     # Affiliate does not get credit. Advertiser does not have to pay.
    'Invalid',      # Stat is Inconclusive (and hidden) from Affiliate but not Advertiser.
    'Adjusted',     # Used for Order whose order total or commission is adjusted.
    'Full Return',  # Used for Order that are fully returned.
    'Published',
  ].freeze

  STATUSES = [
    'Published',
    'Approved',
    'Confirmed',
    'Pending',
    'Adjusted',
    'Full Return',
    'Rejected',
    'Invalid',
    'Duplicate IP',
    'Exceed Cap',                     # when conversion exceed cap
    'Suppressed',                     # when conversion is suppressed
    'Manual Credit',                  # when conversion is manually credited
    'Test Conversion',                # when conversion is a test
    'Manual Approval',                # when conversion needs to be manually approved by advertiser
    'Beyond Referral Period',         # when transaction is recorded beyond its referral period
    'No Active Campaign',             # when transaction has no active campaign
    'Negative Margin',                # When transaction is auto-rejected due to negative margin
    'Duplicate Order',                # when transaction has a high possibility of duplicated orders
    'Duplicate Advertiser Uniq ID',   # When transaction has duplicate advertiser uniq id recorded by our system
  ].freeze

  included do
    self.primary_key = :id

    belongs_to :image_creative, inverse_of: name.tableize
    belongs_to :text_creative, inverse_of: name.tableize
    belongs_to :affiliate_offer, inverse_of: name.tableize
    belongs_to :mkt_site, inverse_of: name.tableize
    belongs_to :ad, inverse_of: name.tableize
    belongs_to :copy_order, class_name: 'Order', foreign_key: 'order_id', inverse_of: copy_stat_relation_name, touch: true

    has_many :orders, inverse_of: name.underscore, foreign_key: :affiliate_stat_id, dependent: :destroy
    has_many :postbacks, inverse_of: name.underscore, foreign_key: :affiliate_stat_id, dependent: :destroy
    has_many :media_categories, through: :affiliate

    has_one :stat_score_info, inverse_of: name.underscore, foreign_key: :affiliate_stat_id, dependent: :destroy
    has_one :missing_order, through: :copy_order

    # TODO: Reduce aliases as possible: creates confusion
    alias_attribute :android_id, :android_uniq
    alias_attribute :user_agent, :http_user_agent
    alias_attribute :ios_id, :ios_uniq
    alias_attribute :banner_creative_id, :image_creative_id
    alias_attribute :order, :order_number
    alias_attribute :payouts, :forex_true_pay
    alias_attribute :commission, :affiliate_pay
    alias_attribute :commissions, :forex_affiliate_pay
    alias_attribute :conversion_margin, :calculated_margin
    alias_attribute :transaction_types, :status
    alias_attribute :transaction_status, :approval

    alias_method :transaction_id, :id

    set_forexable_reader_attributes :calculated_margin
    set_forexable_attributes :true_pay, :affiliate_pay, :order_total, :order_total_for_affiliate, allow_nil: true
    set_local_time_attributes :recorded_at, :captured_at, :published_at, :converted_at, :updated_at
    set_maskable_address_attributes :ip_address

    define_constant_methods APPROVALS, :approval
    define_constant_methods STATUSES, :status, prefix: :order, prefix_scope: :with_order, prefix_instance: :order

    scope_by_browser
    scope_by_country :ip_country
    scope_by_device
    scope_by_image_creative
    scope_by_step_name

    # Clicks has no order_id.
    scope :clicks, -> { where('clicks > ?', 0) }
    scope :conversions, -> { where('conversions > ?', 0) }
    scope :single_conversions, -> { conversions.where(order_id: nil) }
    scope :multi_conversions, -> { conversions.where.not(order_id: nil) }
    scope :meaningful, -> (user_role) {
      if (user_role == :network)
        where('COALESCE(conversions, 0) = 0 OR COALESCE(order_total, 0) != 0 OR COALESCE(true_pay, 0) != 0')
      elsif user_role == :affiliate
        where('COALESCE(conversions, 0) = 0 OR COALESCE(affiliate_pay, 0) != 0')
      end
    }
    scope :meaningless, -> { where(conversions: 1, order_total: [0, nil], true_pay: [0, nil], affiliate_pay: [0, nil]) }
    scope :non_invalid, -> { where.not(approval: approval_invalid) }
    scope :non_rejected, -> { where.not(approval: approval_rejected) }
    scope :with_beyond_referral_period_rule, -> { where(Stat.beyond_referral_period_rule_sql) }
    scope :for_ad_links, -> { where(subid_1: 'adlinks') }
    scope :negative_margin, -> {
      where('COALESCE(true_pay, 0) < COALESCE(affiliate_pay, 0)')
        .where('order_total >= 0')
    }
    scope :zero_margin, -> { where('COALESCE(true_pay, 0) - COALESCE(affiliate_pay, 0) = 0') }
    scope :with_adv_uniq_ids, -> (adv_uniq_ids) { where.not(adv_uniq_id: nil).where(adv_uniq_id: adv_uniq_ids) }

    # TODO: If these methods are being created for download purposes only,
    # please see download_formatters in Downloadable.rb
    delegate :name, :contact_email, :status, :billing_email, :payment_term, :payment_term_days, :universal_number,
      to: :network,
      prefix: true,
      allow_nil: true

    delegate :full_name, :status, to: :affiliate, prefix: true, allow_nil: true
    delegate :name, :status, to: :offer, prefix: true, allow_nil: true

    # TODO: Too many aliased methods here, please avoid.
    # For future reference, please refactor in order avoid creating multiple aliases for the same method.
    delegate :real_total, :true_currency_code, to: :copy_order, prefix: :order, allow_nil: true
  end

  module ClassMethods
    def copy_stat_relation_name
      valid_name = name.gsub('AffiliateStat', 'Stat').gsub('BotStat', 'Stat')
      "copy_#{valid_name.underscore}".to_sym
    end

    def translate_forex_sql(column, currency_code: Currency.platform_code)
      <<-SQL.squish
        (1 / JSON_UNQUOTE(JSON_EXTRACT(forex, concat('$.', COALESCE(original_currency, '#{Currency.platform_code}'))))) *
        (JSON_UNQUOTE(JSON_EXTRACT(forex,  concat('$.', '#{currency_code}')))) * #{column}
      SQL
    end
  end

  def affiliate_offer
    return @affiliate_offer if @affiliate_offer.present?

    @affiliate_offer = AffiliateOffer.cached_find(self[:affiliate_offer_id])
    @affiliate_offer ||= AffiliateOffer.best_match(cached_affiliate, cached_offer)
    @affiliate_offer ||= AffiliateOffer.best_match(cached_affiliate, cached_offer_variant&.cached_offer)
    @affiliate_offer
  end

  def affiliate_offer_id
    affiliate_offer&.id
  end

  def country
    @country ||= Country.cached_find_by(name: ip_country)
  end

  # Retrieve the original stat where this stat comes from.
  # For example: original click may generate multiple conversions.
  # When one of the conversions call this method, it will return the original click stat.
  def original
    @original ||= begin
      if clicks?
        self
      else
        click_stat = copy_order&.affiliate_stat

        Sentry.capture_exception(Exception.new("Click Stat not found for #{id}")) if Rails.env.production? && click_stat.blank?

        return if click_stat.blank?
        return click_stat if click_stat.clicks?
        return click_stat.original if click_stat.original&.clicks?
      end
    end
  end

  def referer_domain
    uri = URI.parse(http_referer)
    uri = URI.parse("http://#{http_referer}") if uri.scheme.nil?
    uri.host.downcase if uri.present? && uri.host.present?
  rescue StandardError
    http_referer.to_s.split('/')[2]
  end

  def original_id
    original&.id
  end

  def original_days_to_return
    copy_order&.days_return.to_i
  end

  # Indicate whether this stat has conversion based on the user type.
  def has_any_conversion?(user_role)
    if user_role == :affiliate
      conversions.to_i > 0 || orders.valid_commissions.any?
    else
      conversions.to_i > 0 || orders.any?
    end
  end

  def conversion_step(step_name = nil)
    conv_step = offer&.conversion_step(step_name || self.step_name)
    conv_step ||= offer&.cached_default_conversion_step
    conv_step
  end

  def considered_pending?(user_role = nil)
    AffiliateStat.approvals_considered_pending(user_role).include?(approval)
  end

  def converted?
    conversions? && captured_at.present?
  end

  def considered_approved?(user = nil)
    AffiliateStat.approvals_considered_approved(user).include?(approval)
  end

  def considered_rejected?
    AffiliateStat.approvals_considered_rejected.include?(approval)
  end

  def considered_final?(user = nil)
    AffiliateStat.approvals_considered_final(user).include?(approval)
  end

  def pending_with_conversion?
    pending? && conversions?
  end

  def inconclusive?
    approval == AffiliateStat.approval_invalid
  end

  def postback_count
    postbacks.count
  end

  def postback_stats
    return if original.blank?

    @postback_stats ||= begin
      current_postbacks = Postback.where(affiliate_stat_id: [id, original.id])
      {
        incoming: current_postbacks.incoming.count,
        outgoing: current_postbacks.outgoing.count,
      }
    end
  end

  def calculated_margin(currency_code = Currency.platform_code)
    forex_true_pay(currency_code).to_f - forex_affiliate_pay(currency_code).to_f
  end

  def forex_order_total(currency_code = Currency.platform_code)
    copy_order&.forex_total(currency_code).to_f
  end

  def steps
    step_label || step_name
  end

  def days_return
    conversion_step&.days_to_return
  end

  def order_number
    super.presence || copy_order&.order_number
  end

  def order_total
    super.presence || copy_order&.total
  end

  def error_payload
    if copy_order.present?
      { order_number: copy_order.order_number }
    else
      { transaction_id: original.id }
    end
  end

  def partition?
    AffiliateStat::PARTITIONS.include?(self.class)
  end

  def unconditioned_original
    @unconditioned_original ||= if partition?
      AffiliateStat.find_by_id(id) || self
    else
      self
    end
  end

  def skip_api_refresh?
    !!skip_api_refresh
  end

  def skip_api_refresh
    @skip_api_refresh ||= !!unconditioned_original.try(:flag, :skip_api_refresh)
  end

  def skip_api_refresh=(value)
    unconditioned_original.try(:flag, :skip_api_refresh, to_boolean(value))
  end

  def true_currency_code
    @true_currency_code ||= if conv_step = conversion_step(step_name)
      conv_step.true_currency.code
    else
      Currency.platform_code
    end
  end

  def real_total
    @real_total ||= if current_currency_code.present? && order_total.present?
      order_total * Currency.rate(Currency.platform_code, true_currency_code, forex)
    elsif order_total.present?
      order_total
    end

    @real_total ? @real_total.round(2) : nil
  end

  def real_true_pay
    @real_true_pay ||= if current_currency_code.present? && true_pay.present?
      true_pay * Currency.rate(Currency.platform_code, true_currency_code, forex)
    elsif true_pay.present?
      true_pay
    end

    @real_true_pay ? @real_true_pay.round(2) : nil
  end

  def order_total_for_affiliate
    affiliate_conv_type == ConversionStep::CONV_TYPE_CPS ? order_total : nil
  end

  def transaction_locked?
    DotOne::Utils.date_convertable?(converted_at) && considered_approved?
  end
end
