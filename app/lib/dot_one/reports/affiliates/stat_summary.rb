class DotOne::Reports::Affiliates::StatSummary < DotOne::Reports::StatSummary
  METRICS = [
    :clicks,
    :impressions,
    :captured,
    :pending_conversions,
    :published_conversions,
    :rejected_conversions,
    :conversion_percentage,
    :total_affiliate_pay,
    :avg_affiliate_pay,
    :published_affiliate_pay,
    :pending_affiliate_pay,
    :rejected_affiliate_pay,
    :affiliate_pay_epc,
  ]

  DIMENSIONS = [
    :offer_id, :offer_variant_id, :ad_slot_id, :image_creative_id, :text_creative_id,
    :subid_1, :subid_2, :subid_3, :subid_4, :subid_5
  ]

  DEFAULT_COLUMNS = {
    recorded_at: [
      :date,
      :clicks,
      :captured,
      :published_conversions,
      :pending_conversions,
      :rejected_conversions,
      :total_affiliate_pay,
      :conversion_percentage,
      :affiliate_pay_epc,
    ],
    captured_at: [
      :date,
      :captured,
      :published_conversions,
      :pending_conversions,
      :rejected_conversions,
      :total_affiliate_pay,
    ],
    converted_at: [
      :date,
      :captured,
      :published_conversions,
      :rejected_conversions,
      :total_affiliate_pay,
    ],
  }.freeze

  def self.dimensions
    DIMENSIONS
  end

  def self.metrics
    METRICS
  end

  def self.extra_columns
    []
  end

  def self.default_columns
    DEFAULT_COLUMNS
  end

  def generate
    super.filter_out_blanks(params[:columns_required])
  end
end
