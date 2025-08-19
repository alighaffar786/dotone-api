class DotOne::Stats::QueryBuilder
  include StatHelpers::Query

  attr_accessor :select_columns, :aggregate_columns, :date_type, :period, :currency_code, :time_zone,
    :sort_field, :sort_order, :user_role

  def initialize(select_columns, aggregate_columns, options = {})
    @select_columns = select_columns.map(&:to_sym)
    @aggregate_columns = aggregate_columns.map(&:to_sym)
    @options = options.transform_values(&:presence)
    @date_type = @options[:date_type] || :recorded_at
    @period = @options[:period] || :day
    @currency_code = @options[:currency_code] || Currency.current_code
    @time_zone = @options[:time_zone] || TimeZone.current
    @user_role = @options[:user_role]&.to_sym || :affiliate
    @sort_field = @options[:sort_field]&.to_sym || :date
    @sort_order = @options[:sort_order] || :asc
  end

  def select_sql
    statements = stat_columns
    statements << "#{date_sql} AS date" if date_sql
    statements << aggregate_sql
    statements.compact.join(',').squish
  end

  def group_sql
    statements = stat_columns
    statements << date_sql if date_sql
    statements.join(',').squish
  end

  def order_sql
    return if sort_field.blank? || (select_columns.exclude?(sort_field) && aggregate_columns.exclude?(sort_field))

    "#{sort_field} #{sort_order}"
  end

  def date_sql
    return unless select_columns.include?(:date)

    self.class.date_sql(date_type, period, time_zone)
  end

  def aggregate_sql
    return if aggregate_columns.blank?

    statements = aggregate_columns.map do |column|
      statement = self.class.send("#{column}_sql", currency_code: currency_code, user_role: user_role)
      "#{statement} AS #{column}"
    end

    statements.join(',').squish
  end

  private

  def stat_columns
    Stat.column_names.map(&:to_sym) & select_columns
  end
end
