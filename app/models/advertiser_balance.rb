class AdvertiserBalance < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Forexable
  include LocalTimeZone
  include AdvertiserBalanceHelpers::Downloadable
  include Relations::NetworkAssociated

  RECORD_TYPES = [
    'Setup Fee',
    'Security Deposit',
    'Advertising Fee',
    'Prepay',
    'Activity Fee',
    'Withdrawal',
    'Other',
  ].freeze

  alias_attribute :sales_tax, :tax

  validates :network_id, :recorded_at, :record_type, presence: true
  validates :record_type, inclusion: { in: RECORD_TYPES }

  validates_with AdvertiserBalanceHelpers::Validator::AdvertiserBalanceValidator

  define_constant_methods RECORD_TYPES, :record_type

  set_forexable_attributes :debit, :credit, :tax, :sales_tax, :final_balance, :invoice_amount
  set_local_time_attributes :recorded_at, :updated_at, :invoice_date

  scope :part_of_balance, -> { where(record_type: AdvertiserBalance.record_types_part_of_balance) }
  scope :recent, -> { order(recorded_at: :desc, id: :desc) }

  scope :previous_records, -> (current) {
    where('recorded_at <= ?', current.recorded_at || Time.now)
      .where(network_id: current.network_id)
      .where.not(id: current.id)
      .order(recorded_at: :desc, id: :desc)
  }

  scope :next_records, -> (current) {
    where('recorded_at >= ?', current.recorded_at || Time.now)
      .where(network_id: current.network_id)
      .where.not(id: current.id)
      .order(recorded_at: :asc, id: :asc)
  }

  scope :agg_final_balance, -> {
    part_of_balance
      .select(
        <<-SQL.squish
          advertiser_balances.network_id,
          (SUM(COALESCE(credit, 0)) - SUM(COALESCE(debit, 0)) - SUM(COALESCE(tax, 0))) AS final_balance
        SQL
      )
      .group(:network_id)
      .except(:order)
  }

  def self.record_types_part_of_balance
    [
      record_type_advertising_fee,
      record_type_prepay,
      record_type_activity_fee,
      record_type_withdrawal,
      record_type_other,
      nil,
      '',
    ]
  end

  def part_of_balance?
    AdvertiserBalance.record_types_part_of_balance.include?(record_type)
  end

  def original_currency
    @original_currency ||= network.original_currency
  end

  def previous_records
    AdvertiserBalance.previous_records(self)
  end

  def next_records
    AdvertiserBalance.next_records(self)
  end

  def previous_one
    @previous_one ||= previous_records.first
  end

  def next_one
    @next_one ||= next_records.first
  end

  def final_balance
    @final_balance ||= begin
      return self[:final_balance] if self[:final_balance].present?
      return 0 unless part_of_balance?

      previous_balance = previous_records.agg_final_balance[0]&.final_balance
      previous_balance.to_f +
        credit.to_f -
        debit.to_f -
        tax.to_f
    end
  end
end
