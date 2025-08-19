class DotOne::Reports::AffiliateUsers::StatSummary < DotOne::Reports::StatSummary
  METRICS = [
    :impressions,
    :clicks,
    :captured,
    :pending_conversions,
    :published_conversions,
    :approved_conversions,
    :rejected_conversions,
    :invalid_conversions,
    :conversion_percentage,
    :rejected_rate,
    :true_pay_epc,
    :affiliate_pay_epc,
    :avg_true_pay,
    :pending_true_pay,
    :published_true_pay,
    :approved_true_pay,
    :total_true_pay,
    :avg_affiliate_pay,
    :pending_affiliate_pay,
    :published_affiliate_pay,
    :approved_affiliate_pay,
    :total_affiliate_pay,
    :order_total,
    :margin,
    :pending_margin,
    :published_margin,
    :total_margin,
  ]

  DIMENSIONS = [
    :offer_id, :offer_variant_id, :affiliate_id, :network_id, :isp, :browser, :ip_country,
    :browser_version, :device_type, :device_brand, :device_model, :ad_slot_id,
    :image_creative_id, :text_creative_id, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5
  ]

  EXTRA_COLUMNS = [
    :media_categories, :contact_lists, :network_contact_email, :network_status, :network_billing_email,
    :network_payment_term, :network_payment_term_days, :network_universal_number, :network_country
  ]

  DEFAULT_COLUMNS = {
    recorded_at: [
      :date,
      :clicks,
      :captured,
      :published_conversions,
      :approved_conversions,
      :conversion_percentage,
      :true_pay_epc,
      :affiliate_pay_epc,
      :approved_true_pay,
      :approved_affiliate_pay,
      :margin
    ],
    captured_at: [
      :date,
      :captured,
      :published_conversions,
      :approved_conversions,
      :approved_true_pay,
      :approved_affiliate_pay,
      :margin
    ],
    published_at: [
      :date,
      :captured,
      :published_conversions,
      :approved_conversions,
      :approved_true_pay,
      :approved_affiliate_pay,
      :margin
    ],
    converted_at: [
      :date,
      :captured,
      :approved_conversions,
      :approved_true_pay,
      :approved_affiliate_pay,
      :margin
    ]
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

  def generate
    result = super.filter_out_blanks(params[:columns_required])

    return result if user.upper_team?

    result.with_affiliate_users(user)
  end

  def generate_top_perfomers
    date_range = params[:time_zone].local_range(:last_7_days)

    params.merge!(
      start_date: date_range[0],
      end_date: date_range[1],
      date_type: :converted_at,
    )

    generate
      .with_approvals(AffiliateStat.approvals_considered_approved)
      .order(total_true_pay: :desc).limit(5)
  end

  def generate_overview
    click_params = params.merge(columns: [:clicks], date_type: :recorded_at)
    pending_params = params.merge(
      columns: [:pending_true_pay, :pending_affiliate_pay, :pending_margin],
      date_type: :captured_at,
    )
    published_params = params.merge(
      columns: [:published_conversions, :published_true_pay, :published_affiliate_pay, :published_margin],
      date_type: :published_at,
    )

    [:today, :yesterday, :this_month, :last_month, :this_year].to_h do |range|
      date_range = time_zone.local_range(range)
      range_params = { start_date: date_range[0], end_date: date_range[1] }

      click_summary = self.class.new(ability, click_params.merge(range_params)).total
      pending_summary = self.class.new(ability, pending_params.merge(range_params)).total
      published_summary = self.class.new(ability, published_params.merge(range_params)).total

      result = click_summary.merge(pending_summary).merge(published_summary)

      result.merge!(
        total_true_pay: result[:pending_true_pay].to_f + result[:published_true_pay].to_f,
        total_affiliate_pay: result[:pending_affiliate_pay].to_f + result[:published_affiliate_pay].to_f,
        total_margin: result[:pending_margin].to_f + result[:published_margin].to_f,
      )

      [range, result]
    end
  end
end
