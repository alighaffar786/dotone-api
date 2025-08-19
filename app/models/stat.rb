class Stat < DatabaseRecords::RedshiftRecord
  include DateRangeable
  include Scopeable
  include StatHelpers::Downloadable
  include StatHelpers::Query

  belongs_to :network
  belongs_to :offer
  belongs_to :affiliate
  belongs_to :offer_variant
  belongs_to :image_creative
  belongs_to :text_creative
  belongs_to :affiliate_offer
  belongs_to :language
  belongs_to :mkt_site
  belongs_to :campaign
  belongs_to :channel
  belongs_to :copy_order, class_name: 'Order', foreign_key: 'order_id'

  has_many :orders
  has_many :postbacks

  has_one :stat_score_info

  attr_accessor :advertiser_registrations, :affiliate_registrations

  scope_by_affiliate
  scope_by_offer
  scope_by_network
  scope_by_status
  scope_by_channel
  scope_by_campaign
  scope_by_step_name
  scope_by_approval
  scope_by_browser
  scope_by_device
  scope_by_image_creative
  scope_by_affiliate_offer
  scope_by_billing_region(:network_id)

  scope :with_payment_term, -> (*args) {
    where('networks.payment_term = ?', args) if args.present? && args[0].is_a?(String)
  }

  scope :pending_by_date_range, -> (columns = [], time_zone: nil, user_role: nil) {
    sqls = columns.map do |column|
      Stat.send("#{column}_sql", time_zone: time_zone, user_role: user_role)
    end

    select(sqls.join(', '))
  }

  scope :stat, -> (select_columns = [], aggregate_columns = [], options = {}) {
    query_builder = DotOne::Stats::QueryBuilder.new(select_columns, aggregate_columns, options)
    result = select(query_builder.select_sql)
      .group(query_builder.group_sql)
      .order(query_builder.order_sql)

    result
  }

  scope :with_offer_variants, -> (*args) {
    column_name = 'stats.offer_variant_id'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_subid_1s, -> (*args) {
    column_name = 'stats.subid_1'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_subid_2s, -> (*args) {
    column_name = 'stats.subid_2'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_subid_3s, -> (*args) {
    column_name = 'stats.subid_3'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_subid_4s, -> (*args) {
    column_name = 'stats.subid_4'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_subid_5s, -> (*args) {
    column_name = 'stats.subid_5'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_gaid, -> (*args) {
    column_name = 'stats.gaid'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :with_ad_slots, -> (*args) {
    column_name = 'stats.ad_slot_id'
    if args.present? && args[0].present? && args[0].is_a?(Array)
      values = args[0]
      where({ column_name => values })
    end
  }

  scope :payout_delta, -> (options) {
    user = options[:user]
    time_zone = options[:time_zone] || TimeZone.platform
    currency_code = options[:currency_code] || Currency.default_code
    forex_translation = Stat.translate_forex_sql(:true_pay, currency_code: currency_code)
    ability = Ability.new(user)

    return if ability.cannot?(:read, NetworkOffer) && ability.cannot?(:read, Affiliate)

    period = options[:period]
    sort_order = options[:sort_order].presence || :asc
    sort_field = options[:sort_field].presence || :delta_percentage
    dimension = options[:dimension].presence || :offer_id

    start_time, end_old_period, end_time = time_zone.local_time_adjacent_periods(period&.to_sym)
    end_time = end_time.utc
    start_time = start_time.utc
    end_old_period = end_old_period.utc
    previous_period_seconds = end_old_period - start_time
    current_period_seconds = end_time - end_old_period

    query = select(dimension)
      .select("CAST(COALESCE(SUM(CASE WHEN captured_at >= '#{start_time}' AND captured_at < '#{end_old_period}' THEN #{forex_translation} END), 0) AS DECIMAL(20,2)) AS total_payout_past_period")
      .select("COALESCE(SUM(CASE WHEN captured_at >= '#{end_old_period}' THEN #{forex_translation} END), 0) AS total_payout_current_period")
      .select("CAST(total_payout_past_period / #{previous_period_seconds} AS DECIMAL(20,4)) AS past_period_dollar_unit")
      .select("past_period_dollar_unit * #{current_period_seconds} AS pivot_dollar_unit")
      .select('total_payout_current_period - pivot_dollar_unit AS delta_amount')
      .select('CASE WHEN total_payout_past_period > 0 THEN (delta_amount / total_payout_past_period) * 100 ELSE delta_amount END AS delta_percentage')
      .select("COALESCE(SUM(CASE WHEN captured_at >= '#{end_old_period}' THEN #{forex_translation} END), 0) AS total_true_pay")

    query = query.with_affiliate_users(user) if user.manager?
    query
      .group(dimension)
      .order("#{sort_field} #{sort_order}")
  }

  # TODO: Handle pending conversion count based on certain timezone
  scope :pending_conversion_counts, -> {
    select('offer_id, sum(conversions)')
      .pending
      .has_conversions
      .where("to_char(recorded_at, 'YYYY-MM-DD') >= ?", 6.months.ago.to_date.to_s)
      .group(:offer_id)
      .map { |stat| [stat.offer_id, stat.sum] }
      .to_h
  }

  scope :non_rejected, -> { where.not(approval: AffiliateStat.approval_rejected) }

  # clicks has no order_id.
  scope :clicks, -> { where('clicks > ?', 0) }

  scope :has_conversions, -> { where('conversions > ?', 0) }

  scope :has_channel, -> { where.not(channel_id: nil) }

  scope :has_adv_uniq_id, -> { where.not(adv_uniq_id: nil) }

  scope :for_ad_links, -> { where(subid_1: 'adlinks') }

  scope :pending, -> { where(approval: AffiliateStat.approval_pending) }

  scope :recorded_at, -> (timestamp) { where('recorded_at >= ?', timestamp) }

  scope :meaningful, -> (user_role) {
    if user_role == :network
      where('COALESCE(conversions, 0) = 0 OR COALESCE(order_total, 0) != 0 OR COALESCE(true_pay, 0) != 0')
    elsif user_role == :affiliate
      where('COALESCE(conversions, 0) = 0 OR COALESCE(affiliate_pay, 0) != 0')
    end
  }

  scope :meaningless, -> { where(conversions: 1, order_total: [0, nil], true_pay: [0, nil]) }

  ##
  # Scope to determine impression stats
  # need to be excluded when impression
  # is not being requested
  scope :filter_out_impressions, -> (*args) {
    columns = args[0].to_a.map(&:to_sym)
    where('clicks > 0 OR conversions > 0') if columns.include?(:clicks) && !columns.include?(:impressions)
  }

  ##
  # Scope to filter out any row with blank value
  # on each column specified in cols array
  scope :filter_out_blanks, -> (*args) {
    if args[0].present? &&
        sqls = args.flatten.map { |col| "#{col} IS NOT NULL" }
      where(sqls.join(' AND '))
    end
  }

  scope :with_affiliate_users, -> (*args) {
    if Scopeable.args_valid?(args)
      affiliate_users = if args[0].is_a?(ActiveRecord::Relation)
        args[0]
      else
        AffiliateUser.where(id: args.flatten.map { |x| x.id rescue x })
      end

      aff_ids = affiliate_users.managed_affiliate_ids
      adv_ids = affiliate_users.managed_network_ids

      if aff_ids.present? && adv_ids.present?
        with_affiliates(aff_ids).or(with_networks(adv_ids))
      elsif aff_ids.present?
        with_affiliates(aff_ids)
      elsif adv_ids.present?
        with_networks(adv_ids)
      end
    end
  }

  scope :with_recruiters, -> (*args) {
    if Scopeable.args_valid?(args)
      affiliate_users = if args[0].is_a?(ActiveRecord::Relation)
        args[0]
      else
        AffiliateUser.where(id: args.flatten.map { |x| x.id rescue x })
      end

      aff_ids = affiliate_users.recruited_affiliate_ids
      adv_ids = affiliate_users.recruited_network_ids

      if aff_ids.present? && adv_ids.present?
        with_affiliates(aff_ids).or(with_networks(adv_ids))
      elsif aff_ids.present?
        with_affiliates(aff_ids)
      elsif adv_ids.present?
        with_networks(adv_ids)
      end
    end
  }


  scope :with_countries, -> (*args) {
    if args[0].present?
      values = [args, Country.international].flatten
      countries = if args[0].is_a?(ActiveRecord::Relation)
        values
      else
        Country.where(id: values.map { |x| x.id rescue x })
      end


      where(ip_country: countries.pluck(:name))
    end
  }

  def self.date_limit
    2.years.ago.to_date.beginning_of_month
  end

  def self.exec_sql(sql)
    retries = 0

    begin
      connection.execute(sql)
    rescue PG::ConnectionBad => e
      raise e if retries > 15

      sleep 60
      retries += 1
      retry
    end
  end

  def self.network_pending_payouts
    stat([:network_id], [:pending_true_pay], currency_code: Currency.current_code, user_role: :network)
      .where('captured_at > ?', 180.days.ago)
      .index_by(&:network_id)
  end

  def self.network_published_payouts
    stat([:network_id], [:published_true_pay], currency_code: Currency.current_code, user_role: :network)
      .between(*TimeZone.current.local_range(:this_month), :published_at)
      .index_by(&:network_id)
  end

  def def(affiliate_offer)
    return @affiliate_offer if @affiliate_offer.present?

    @affiliate_offer = super
    @affiliate_offer ||= AffiliateOffer.best_match(affiliate, offer)
    @affiliate_offer ||= AffiliateOffer.best_match(affiliate, offer_variant.try(:offer))
  end

  def affiliate_offer_id
    affiliate_offer&.id
  end

  def network_name
    network&.name
  end

  def to_affiliate_stat
    return if AffiliateStat.exists?(id: id)

    AffiliateStat.create!(attributes.slice(*AffiliateStat.column_names))
  end
end
