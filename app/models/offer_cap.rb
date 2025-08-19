class OfferCap < DatabaseRecords::PrimaryRecord
  include HasCap
  include Traceable

  STAGE_1_DEPLETING_RATIO = 0.90
  STAGE_2_DEPLETING_RATIO = 0.95

  belongs_to :offer_variant, inverse_of: :offer_cap, touch: true

  has_one :offer, through: :offer_variant
  has_one :network, through: :offer
  has_one :time_zone, through: :network

  validates :offer_variant_id, presence: true
  validates :cap_type, inclusion: { in: CAP_TYPES, allow_blank: true }
  validates :cap_size, presence: true, if: -> { cap_type.present? }

  after_save :schedule_reset_cap

  alias_attribute :cap_earliest_at, :earliest_at
  alias_attribute :cap_size, :number
  alias cap_time_zone_item time_zone

  def self.date_range_map
    {
      cap_type_monthly_cap => :this_month,
      cap_type_daily_cap => :today,
      cap_type_lifetime_cap => :lifetime,
    }
  end

  def offer_id
    offer_variant.offer_id
  end

  def reset_cap!
    return if cap_type.blank?

    if number.blank?
      offer.flag(:cap_depleted, false)
    elsif (number.to_i - conversion_so_far) > 0
      offer.flag(:cap_depleted, false)
    elsif (number.to_i - conversion_so_far) <= 0
      offer.flag(:cap_depleted, true)
    end
  end
end
