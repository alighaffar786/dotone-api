class DotOne::Services::PartitionGenerator
  attr_accessor :table_name, :date_column

  def initialize(table_name = :affiliate_stats, date_column = :recorded_at)
    @table_name = table_name
    @date_column = date_column
  end

  def add(year)
    sql = partition_sql(year)
    return if sql.blank?

    execute(
      <<-SQL.squish
        ALTER TABLE #{table_name} ADD PARTITION (#{sql})
      SQL
    )
  end

  def create(year)
    sql = partition_sql(year)
    return if sql.blank?

    execute(
      <<-SQL.squish
        ALTER TABLE #{table_name} PARTITION BY RANGE (TO_DAYS(#{date_column})) (#{sql})
      SQL
    )
  end

  def drop(year)
    execute(
      <<-SQL.squish
        ALTER TABLE #{table_name} DROP PARTITION #{partition_sql(year, 'drop')}
      SQL
    )
  end

  def list
    @list ||= execute(
      <<-SQL.squish
        SELECT
          table_name,
          partition_name,
          partition_ordinal_position,
          partition_method,
          partition_expression,
          partition_description,
          table_rows
        FROM
          information_schema.partitions
        WHERE
          table_schema = DATABASE() AND
          table_name = '#{table_name}';
      SQL
    )
  end

  def execute(sql)
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def partition_sql(year, mode = nil)
    sql = []

    1.upto(12) do |month|
      month_string = '%02d' % month
      partitions = [
        2, 4, 6, 8, 10, 12, 14, 16, 18,
        20, 22, 24, 26, 28, 30
      ]

      partitions.each_with_index do |date, subpart|
        next if month == 2 and date > 28

        # Build partition name
        subpart_string = '%02d' % subpart
        partition_name = "p#{year}#{month_string}SUB#{subpart_string}"

        # Build timestamp
        month_part = '%02d' % month
        date_part = '%02d' % date
        timestamp = "#{year}-#{month_part}-#{date_part} 00:00:00"

        next if mode.nil? && list.any? { |item| item[1] == partition_name }

        sql << if mode == 'drop'
          partition_name
        else
          "  PARTITION #{partition_name} VALUES LESS THAN (TO_DAYS('#{timestamp}'))"
        end
      end
    end

    sql.join(',')
  end
end
