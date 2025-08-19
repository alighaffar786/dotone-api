class DotOne::Reports::Networks::StatSummary < DotOne::Reports::StatSummary
  METRICS = [
    :clicks,
    :impressions,
    :captured,
    :pending_conversions,
    :published_conversions,
    :rejected_conversions,
    :conversion_percentage,
    :order_total,
    :total_true_pay,
    :published_true_pay,
    :pending_true_pay,
    :rejected_true_pay,
    :true_pay_epc,
    :roas,
  ]

  DIMENSIONS = [:affiliate_id, :text_creative_id, :offer_id, :image_creative_id]

  EXTRA_COLUMNS = [:media_categories]

  DEFAULT_COLUMNS = {
    recorded_at: [
      :clicks,
      :captured,
      :published_conversions,
      :pending_conversions,
      :rejected_conversions,
      :order_total,
      :total_true_pay,
      :conversion_percentage,
      :true_pay_epc,
    ],
    captured_at: [
      :captured,
      :published_conversions,
      :pending_conversions,
      :rejected_conversions,
      :order_total,
      :total_true_pay,
      :pending_true_pay,
      :published_true_pay,
      :rejected_true_pay,
    ],
    converted_at: [
      :captured,
      :published_conversions,
      :rejected_conversions,
      :order_total,
      :total_true_pay,
      :published_true_pay,
      :rejected_true_pay,
    ],
  }.freeze

  def self.dimensions
    DIMENSIONS
  end

  def self.metrics
    METRICS
  end

  def self.extra_columns
    EXTRA_COLUMNS
  end

  def self.default_columns
    DEFAULT_COLUMNS
  end
end
