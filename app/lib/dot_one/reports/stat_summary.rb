class DotOne::Reports::StatSummary
  extend ParamNameHelper

  attr_reader :ability, :user, :params, :sort_field, :sort_order, :time_zone, :currency_code

  INTEGER_COLUMNS = [
    :impressions,
    :clicks,
    :captured,
    :pending_conversions,
    :published_conversions,
    :approved_conversions,
    :rejected_conversions,
    :invalid_conversions,
  ]

  FLOAT_COLUMNS = [
    :order_total,
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
    :margin,
    :pending_margin,
    :published_margin,
    :total_margin,
    :roas,
  ]

  COLUMNS = {
    **INTEGER_COLUMNS.to_h { |metric| [metric, :integer] },
    **FLOAT_COLUMNS.to_h { |metric| [metric, :float] },
  }

  def initialize(user, params = {})
    @ability = user.is_a?(Ability) ? user : Ability.new(user)
    @user = ability.user
    @filters = params.select { |k, _| Stat.column_names.include?(k.to_s.singularize) }
    @params = params.reject { |k, _| @filters.keys.include?(k) }
    @time_zone = params[:time_zone] || @user.default_time_zone
    @currency_code = params[:currency_code] || @user.currency_code
    @sort_field = params.delete(:sort_field)
    @sort_order = params.delete(:sort_order)
  end

  def self.dimensions
    raise NotImplementedError
  end

  def self.metrics
    raise NotImplementedError
  end

  def self.extra_columns
    raise NotImplementedError
  end

  def self.default_columns
    raise NotImplementedError
  end

  def self.columns
    [:date] | dimensions | metrics
  end

  def self.downloaded_columns
    columns | extra_columns
  end

  def self.default_metrics_for(date_type)
    date_type = date_type.presence || :recorded_at
    default_columns[date_type.to_sym] || []
  end

  def columns
    @columns = params[:columns].to_a.map(&:to_sym).uniq.presence
    @columns ||= ([:date] | self.class.metrics)
    @columns
  end

  def select_columns
    columns - aggregate_columns
  end

  def aggregate_columns
    self.class.metrics & columns
  end

  def filters
    @filters
      .to_h
      .with_indifferent_access
      .select { |_, v| v.present? }
      .transform_keys(&:singularize)
  end

  def total
    stat = aggregate_columns.present? && query_stats(select_columns: [])
      .filter_out_blanks(params[:columns_required].presence&.reject { |col| col == 'date' })
      .except(:order)[0]
    aggregate_columns.each_with_object({}) do |column, result|
      result[column] = (stat && stat.send(column)) || 0
    end
  end

  def generate
    query_stats.filter_out_impressions(columns)
  end

  def self.download_formatters
    COLUMNS.to_h do |key, value|
      formatter = case value
      when :integer
        -> (record) { record.send(key).to_i }
      when :float
        -> (record) { record.send(key).to_f.round(2) }
      end

      [key, formatter]
    end
  end

  protected

  def query_stats(args = {})
    StatCollection.new(ability, params)
      .collect
      .where(filters)
      .reorder('') # reset order by from StatCollection
      .stat(args[:select_columns] || select_columns, aggregate_columns, {
        date_type: params[:date_type],
        period: params[:period],
        currency_code: currency_code,
        time_zone: time_zone,
        sort_field: sort_field,
        sort_order: sort_order,
        user_role: ability.user_role,
      })
  end
end
