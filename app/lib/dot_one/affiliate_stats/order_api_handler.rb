class DotOne::AffiliateStats::OrderApiHandler
  include ActiveModel::Validations

  BASE_STATUSES = {
    adjust: Order.status_adjusted,
    confirm: Order.status_confirmed,
    reject: Order.status_rejected,
    return: Order.status_full_return,
  }.freeze

  NINE_ONE_APP_STATUSES = {
    create: Order.status_pending,
    cancel: Order.status_rejected,
    finish: Order.status_confirmed,
    return: Order.status_full_return,
  }.freeze

  STATUSES = BASE_STATUSES.merge(NINE_ONE_APP_STATUSES)

  attr_accessor :network, :click_stat, :copy_stat, :order, :offer, :status, :order_total, :revenue, :params, :flexible

  validates :click_stat, :offer, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.keys, allow_nil: false }
  validate :validate_owner

  def initialize(params)
    @network = params.delete(:network)
    @flexible = params.delete(:flexible) # skip validation of owner
    @status = params.delete(:status)&.downcase&.to_sym
    @params = build_params(params)

    obtain_stat_offer_and_order
  end

  def save
    result = { convert: false, errors: 'Data missing' }

    return result unless valid?

    if status != :create && copy_stat.blank?
      result[:errors] = 'Order Not found'
    else
      conversion_options = DotOne::Utils::ConversionOptions.new(user_role: :network)
      result = (copy_stat || click_stat).process_conversion!(conversion_options, params)
    end

    result
  end

  def delay?
    click_stat.blank? || copy_stat.blank?
  end

  private

  def obtain_stat_offer_and_order
    self.click_stat = AffiliateStat.find_by(id: params[:server_subid]) || AffiliateStat.find_by_valid_subid(params[:server_subid])
    self.offer = click_stat&.cached_offer || NetworkOffer.cached_find(params[:offer_id])

    if click_stat&.conversions?
      self.copy_stat = click_stat
    elsif status != :create
      if click_stat && params[:order_number].present?
        self.order = AffiliateStat.find_order(click_stat, params)
      end

      if params[:order_number].present?
        self.order ||= Order.find_by(order_number: params[:order_number], offer_id: offer.id) if offer
        self.order ||= Order.find_by(order_number: params[:order_number], network_id: network.id) if network
      end

      self.click_stat ||= order&.affiliate_stat
      self.copy_stat = order&.copy_stat
    end
  end

  def validate_owner
    return true if flexible
    errors.add(:offer, 'is invalid') if offer.present? && (offer.network != network || copy_stat.present? && copy_stat.offer != offer)
  end

  def build_params(params)
    case @status
    when :create
      params.merge!(
        real_time: true,
        skip_expiration_check: true,
        skip_duplicate_ip_check: true,
        skip_proximity_order: true,
      )
    when :adjust
      params.merge!(
        skip_existing_commission: true,
        skip_existing_payout: true,
      )
    else
      params.delete(:order_total)
      params.delete(:revenue)
      params.merge!(skip_calculation: true, skip_currency_adjustment: true)
    end

    params.merge!(
      approval: STATUSES[@status],
      order_number: params.delete(:order),
      trace_agent_via: 'Advertiser API',
      force: true,
    )

    params
  end
end
