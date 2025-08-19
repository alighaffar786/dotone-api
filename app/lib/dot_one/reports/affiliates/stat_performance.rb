class DotOne::Reports::Affiliates::StatPerformance < DotOne::Reports::Base

  attr_reader :ability, :date_type, :billing_region, :start_date, :end_date

  NUM_OF_DAYS_IN_A_YEAR = 365

  def initialize(affiliate, params = {})
    super(params)
    @ability = affiliate.is_a?(Ability) ? affiliate : Ability.new(affiliate)
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @billing_region = params[:billing_region]
  end

  def query_stats(date_range, date_column, select_columns = [], aggregate_columns = [], options = {})
    Stat.accessible_by(ability)
      .between(*date_range, date_column, time_zone)
      .with_billing_regions(billing_region)
      .stat(select_columns, aggregate_columns, options.merge(currency_code: currency_code, time_zone: time_zone))
  end

  def query_confirmed_stat(date_range)
    query_stats(date_range, :converted_at, [], [
      :approved_conversions,
      :approved_affiliate_pay,
    ])[0]
  end

  def query_event_count(date_range)
    count_events = proc do |params = {}|
      events = EventOfferCollection.new(ability, params.merge(applied: true, sort_field: :id)).collect
      EventAffiliateOfferCollection.new(ability, { event_offer_ids: events.select(:id) })
        .collect
        .where(created_at: date_range)
        .count
    end

    {
      pending: count_events.call,
      confirmed: count_events.call(approval_statuses: AffiliateOffer.approval_status_considered_approved),
    }
  end

  def generate
    result = {}
    aggregate_columns = [:clicks, :captured, :total_affiliate_pay, :conversion_percentage, :affiliate_pay_epc]

    date_range = [start_date, end_date].map do |date|
      date.to_datetime rescue DateTime.now
    end

    num_days = (date_range[1] - date_range[0]).to_i
    period = num_days > NUM_OF_DAYS_IN_A_YEAR ? :month : :day
    stats = query_stats(date_range, :recorded_at, [:date], aggregate_columns, period: period).index_by { |stat| stat.date.to_date }

    (date_range[0].to_i..date_range[1].to_i).step(1.send(period)) do |date|
      d = Time.at(date)
      d = d.beginning_of_month if period == :month
      d = d.to_date

      result[d] = aggregate_columns.to_h do |column|
        [column, stats[d]&.send(column).to_f]
      end
    end

    total = aggregate_columns.each_with_object({}) do |column, r|
      r[column] = result.values.map { |d| d[column] }.sum
    end

    total[:conversion_percentage] = total[:captured] * 100 / (total[:clicks] == 0 ? 1 : total[:clicks]).to_f
    total[:affiliate_pay_epc] = total[:total_affiliate_pay] / (total[:clicks] == 0 ? 1 : total[:clicks]).to_f

    timestamp(result: result, total: total)
  end

  def generate_confirmed
    result = {}

    [:last_month, :this_month].each do |date_range_type|
      date_range = time_zone.local_range(date_range_type)
      stat = query_confirmed_stat(date_range)

      result[date_range_type] = {
        conversions: stat&.approved_conversions.to_i,
        affiliate_pay: stat&.approved_affiliate_pay.to_f,
        date_range: date_range,
        events: query_event_count(date_range),
      }
    end

    timestamp(result)
  end

  private

  def timestamp(data)
    data.merge(generated_at: Time.now)
  end
end
