class Order < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include DateRangeable
  include Forexable
  include LocalTimeZone
  include NameHelper
  include Traceable
  include Relations::AffiliateAssociated
  include Relations::AffiliateStatAssociated
  include Relations::NetworkAssociated
  include Relations::OfferAssociated
  include Relations::OfferVariantAssociated
  include OrderHelpers::EsSearch

  # used to assign some http info from the request and record it under copy stat.
  attr_accessor :http_user_agent, :http_referer, :ip_address
  # Being used for TOKEN_REGEX_ORDER
  alias_attribute :number, :order_number

  # Origin stat
  belongs_to_affiliate_stat

  has_many :conversion_steps, through: :offer

  # Stat reflection of this order
  has_one :copy_stat, class_name: 'AffiliateStat', inverse_of: :copy_order, dependent: :destroy
  has_one :missing_order, inverse_of: :order, dependent: :nullify

  AffiliateStat::PARTITIONS.each do |partition|
    has_one partition.copy_stat_relation_name, class_name: partition.name, inverse_of: :copy_order, dependent: :destroy
  end

  validates :offer_id, :recorded_at, :affiliate_stat, presence: true
  validates :status, inclusion: { in: AffiliateStat::STATUSES }
  validates :order_number, uniqueness: { scope: [:affiliate_stat_id, :step_name, :offer_id, :status] }, allow_blank: true, if: :order_number_changed?

  before_validation :set_defaults
  before_save :adjust_values
  after_save :generate_order_number_if_blank
  after_save :save_to_copy_stat

  define_constant_methods AffiliateStat::STATUSES, :status
  set_forexable_attributes :total, :true_pay, :affiliate_pay
  set_local_time_attributes :recorded_at, :published_at, :converted_at
  trace_as_date :recorded_at, :converted_at, :published_at

  scope :like, -> (*args) {
    if args.present? && args[0].present?
      statements = []
      conditions = []

      statements << 'orders.id = ?'
      conditions << args[0]

      statements << 'orders.order_number LIKE ?'
      conditions << "%#{args[0]}%"

      statements << 'orders.affiliate_stat_id LIKE ?'
      conditions << "%#{args[0]}%"

      conditions = [statements.join(' OR ')] + conditions
      where(conditions)
    end
  }

  scope :valid_commissions, -> { where.not(status: status_invalid) }

  def self.statuses_considered_final
    approvals = AffiliateStat.approvals_considered_final.flat_map do |approval|
      AffiliateStat.approval_status_map[approval]
    end

    approvals.uniq - [AffiliateStat.approval_published]
  end

  def self.statuses_considered_approved
    AffiliateStat.approvals_considered_approved.flat_map do |approval|
      AffiliateStat.approval_status_map[approval]
    end
  end

  def self.statuses_considered_rejected
    AffiliateStat.approvals_considered_rejected.flat_map do |approval|
      AffiliateStat.approval_status_map[approval]
    end
  end

  def id_with_number
    "(#{id}) #{order_number}"
  end

  def affiliate_offer
    AffiliateOffer.best_match(affiliate, offer_variant.offer)
  rescue StandardError
  end

  def calculate(options = {})
    conv_step, step_price, order_total_to_record,
    payout, commission, payout_share, commission_share = affiliate_stat.calculate_payout_and_commission(
      options[:order_total],
      options[:revenue],
      step_name,
      options,
    )

    self.true_pay = payout
    self.affiliate_pay = commission
    self.total = order_total_to_record
  end

  def conversion_step_id
    conversion_step&.id
  end

  def conversion_step_id=(step_id)
    return unless step = ConversionStep.find_by(id: step_id)

    self.step_name = step.name
    self.step_label = step.label
  end

  def true_currency_code
    if conversion_step.present?
      conversion_step.true_currency.code
    else
      Currency.platform_code
    end
  end

  def conversion_step
    @conversion_step ||= conversion_steps.find { |step| step.name == step_name }
  end

  def real_total
    return unless conversion_step.present?

    @real_total ||= if current_currency_code.present? && total.present?
      total * Currency.rate(current_currency_code, true_currency_code, forex)
    elsif total.present?
      total
    end

    @real_total ? @real_total.round(2) : nil
  end

  def real_true_pay
    return unless conversion_step.present?

    @real_true_pay ||= if current_currency_code.present? && true_pay.present?
      true_pay * Currency.rate(current_currency_code, true_currency_code, forex)
    else
      true_pay
    end

    @real_true_pay ? @real_true_pay.round(2) : nil
  end

  def days_return
    @days_return ||= conversion_step&.days_to_return.to_i
  end

  def days_since_order
    (Date.today - recorded_at.to_date).to_i
  end

  def days_return_past_due?
    days_since_order >= days_return
  end

  def auto_number?
    order_number.to_s.include?("AUTO-#{network_id}")
  end

  def with_past_due_as_last
    traces.order(created_at: :desc).first.agent.include?('System - PAST DUE')
  end

  def save_to_copy_stat
    stat_to_save = AffiliateStat.find_by(order_id: id)

    # build copy stat data from order
    attrs = {
      clicks: 0,
      conversions: 1,
      true_pay: true_pay,
      affiliate_pay: affiliate_pay,
      order_id: id,
      step_name: step_name,
      step_label: step_label,
      true_conv_type: true_conv_type,
      affiliate_conv_type: affiliate_conv_type,
      captured_at: recorded_at,
      order_total: total,
      order_number: order_number,
      forex: forex,
      original_currency: Currency.platform_code,
    }

    # add http data if exist
    attrs[:http_user_agent] = http_user_agent if http_user_agent.present?
    attrs[:http_referer] = http_referer if http_referer.present?
    attrs[:ip_address] = ip_address if ip_address.present?

    # copy information from original stat
    original_stat = affiliate_stat
    if original_stat.present?
      attrs = attrs.merge({
        network_id: original_stat.network_id,
        offer_id: original_stat.offer_id,
        offer_variant_id: original_stat.offer_variant_id,
        affiliate_id: original_stat.affiliate_id,
        subid_1: original_stat.subid_1,
        subid_2: original_stat.subid_2,
        subid_3: original_stat.subid_3,
        subid_4: original_stat.subid_4,
        subid_5: original_stat.subid_5,
        gaid: original_stat.gaid,
        language_id: original_stat.language_id,
        recorded_at: original_stat.recorded_at,
        image_creative_id: original_stat.image_creative_id,
        text_creative_id: original_stat.text_creative_id,
        affiliate_offer_id: original_stat.affiliate_offer_id,
        ip_address: original_stat.ip_address,
        ad_slot_id: original_stat.ad_slot_id,
        aff_uniq_id: original_stat.aff_uniq_id,
        campaign_id: original_stat.campaign_id,
        channel_id: original_stat.channel_id,
        ip_country: original_stat.ip_country,
        http_user_agent: original_stat.http_user_agent,
        http_referer: original_stat.http_referer,
        isp: original_stat.isp,
        browser: original_stat.browser,
        browser_version: original_stat.browser_version,
        device_type: original_stat.device_type,
        device_brand: original_stat.device_brand,
        device_model: original_stat.device_model,
        ios_uniq: original_stat.ios_uniq,
        android_uniq: original_stat.android_uniq,
      })
    end

    if Order.statuses_considered_final.include?(status)
      attrs[:published_at] = published_at || converted_at || Time.now
      attrs[:converted_at] = converted_at || Time.now
    elsif published?
      attrs[:published_at] = published_at || converted_at || Time.now
      attrs[:converted_at] = nil
    else
      attrs[:published_at] = nil
      attrs[:converted_at] = nil
    end

    attrs[:status] = status
    attrs[:approval] = AffiliateStat.decide_approval(status)

    # Update or create the stat
    DotOne::Utils::Rescuer.no_deadlock do
      if stat_to_save.blank?
        attrs[:order_id] = id
        stat_to_save = AffiliateStat.create!(attrs)
      else
        stat_to_save.update(attrs)
      end
    end

    raise 'error' if stat_to_save.id.blank?

    stat_to_save
  end

  def forex
    @forex ||= self[:forex].presence || copy_stat&.forex || affiliate_stat.forex
  end

  # format content for order value
  def format_content(content, type, _options = {})
    content = content.gsub(/\r\n/, '') unless type == :email
    content.gsub(TOKEN_REGEX_ORDER) do |_x|
      arg = Regexp.last_match(1)
      if arg.present?
        val = send(arg)
        if type == :url
          val = begin
            CGI.escape(val.to_s)
          rescue StandardError
          end
        end
        val
      end
    end
  end

  def margin
    forex_true_pay.to_f - forex_affiliate_pay.to_f
  end

  def total_as_integer
    total.to_i
  end

  def trace_string
    target_string = []
    target_string << self.class.model_name.human
    target_string << if order_number.present?
      "Number #{order_number}"
    else
      "ID #{id}"
    end
    target_string.join(' ')
  end

  # TODO: deprecated
  def offer_id_with_name
    offer.try(:id_with_name)
  end

  # TODO: deprecated
  # Being used for download purpose only
  def affiliate_stat_recorded_at_local
    affiliate_stat.try(:recorded_at_local)
  end

  def postbacks
    postbacks = Postback.incoming.api_excluded.where(affiliate_stat_id: affiliate_stat_id)

    return postbacks if auto_number?

    postbacks.query_by_order_number(order_number)
  end

  private

  def generate_order_number_if_blank
    reload
    return if order_number.present?

    self.order_number = "AUTO-#{offer.network_id}-#{id}"
    update_column(:order_number, order_number)

    AffiliateStat.where(order_id: id).each { |x| x.update(order_number: order_number) }
    reindex
  end

  def set_defaults
    self.recorded_at ||= published_at || converted_at || Time.now

    if Order.statuses_considered_rejected.include?(status_was) && Order.statuses_considered_approved.include?(status)
      self.published_at = Time.now
      self.converted_at = Time.now
    elsif Order.statuses_considered_final.include?(status)
      self.published_at ||= converted_at || Time.now
      self.converted_at ||= Time.now
    elsif published?
      self.published_at ||= converted_at || Time.now
      self.converted_at = nil
    else
      self.published_at = nil
      self.converted_at = nil
    end
  end

  def adjust_values
    self.network_id ||= offer&.network_id
    self.original_true_pay ||= true_pay
    self.original_total ||= total
    self.forex = copy_stat&.forex || affiliate_stat.forex if self[:forex].blank?
  end
end
