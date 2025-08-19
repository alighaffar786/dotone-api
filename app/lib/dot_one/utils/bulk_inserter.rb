class DotOne::Utils::BulkInserter
  attr_reader :connection, :ignore, :update_duplicates
  attr_accessor :set_size, :before_save_callback, :after_save_callback, :adapter_name

  def initialize(connection, table_name, column_names, set_size = 500, ignore = false, update_duplicates = false)
    @connection = connection
    @set_size = set_size

    @adapter_name = connection.adapter_name
    # INSERT IGNORE only fails inserts with duplicate keys or unallowed nulls not the whole set of inserts
    @ignore = ignore
    @update_duplicates = update_duplicates

    columns = connection.columns(table_name)
    column_map = columns.inject({}) { |h, c| h.update(c.name => c) }

    @columns = column_names.map { |name| column_map[name.to_s] }
    @table_name = connection.quote_table_name(table_name)
    @column_names = column_names.map { |name| connection.quote_column_name(name) }.join(',')

    @before_save_callback = nil
    @after_save_callback = nil

    @set = []
  end

  def pending?
    @set.any?
  end

  def pending_count
    @set.count
  end

  def add(values)
    save! if @set.length >= set_size

    values = values.with_indifferent_access if values.is_a?(Hash)
    mapped = @columns.map.with_index do |column, index|
      value_exists = values.is_a?(Hash) ? values.key?(column.name) : (index < values.length)
      if value_exists
        values.is_a?(Hash) ? values[column.name] : values[index]
      elsif column.default.present?
        column.default
      elsif column.name == 'created_at' || column.name == 'updated_at'
        :__timestamp_placeholder
      end
    end

    @set.push(mapped)
    self
  end

  def add_all(rows)
    rows.each { |row| add(row) }
    self
  end

  def before_save(&block)
    @before_save_callback = block
  end

  def after_save(&block)
    @after_save_callback = block
  end

  def save!
    if pending?
      @before_save_callback.call(@set) if @before_save_callback
      compose_insert_query.tap { |query| @connection.execute(query) if query }
      @after_save_callback.call(@set) if @after_save_callback
      @set.clear
    end

    self
  end

  def compose_insert_query
    sql = insert_sql_statement
    @now = Time.now
    rows = []

    @set.each do |row|
      values = []
      @columns.zip(row) do |column, value|
        value = @now if value == :__timestamp_placeholder

        if ActiveRecord::VERSION::STRING >= '5.0.0'
          value =
            if column
              type = @connection.lookup_cast_type_from_column(column)

              begin
                type.serialize(value)
              rescue ActiveModel::RangeError
              end
            else
              value
            end

          values << @connection.quote(value)
        else
          values << @connection.quote(value, column)
        end
      end

      rows << "(#{values.join(',')})"
    end

    if rows.empty?
      false
    else
      sql << rows.join(',')
      sql << on_conflict_statement
      sql
    end
  end

  def insert_sql_statement
    "INSERT #{insert_ignore} INTO #{@table_name} (#{@column_names}) VALUES "
  end

  def insert_ignore
    return unless ignore

    case adapter_name
    when /^mysql/i
      'IGNORE'
    when /\ASQLite/i # SQLite
      'OR IGNORE'
    else
      '' # Not supported
    end
  end

  def on_conflict_statement
    if adapter_name =~ /\APost(?:greSQL|GIS)/i && ignore
      ' ON CONFLICT DO NOTHING'
    elsif adapter_name =~ /^mysql/i && update_duplicates
      update_values = @columns.map do |column|
        if column.name == 'created_at'
          "created_at=IF(created_at IS NULL, VALUES(created_at), created_at)"
        else
          "#{column.name}=VALUES(#{column.name})"
        end
      end.join(', ')
      " ON DUPLICATE KEY UPDATE #{update_values}"
    else
      ''
    end
  end
end
