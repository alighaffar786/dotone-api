# Source: https://gist.github.com/mmrwoods/647245/6e7a84b2bf831cafa471e2c983b4e0ec0c68449c
# Helper to manage migration (add/remove column, add/remove index) 
# to the table with large numbers of data.
# The code has been modified to work with this app's set of gems and sql adapter.

# Requirement: Table should have `updated_at` column that is guaranteed to be refreshed
# for each update or insert in order to have this script to work properly.

# PLEASE MAKE SURE TO TEST IN ADVANCE BEFORE RUNNING IT AGAINST PRODUCTION DB
module MysqlBigTableMigrationHelper

  # Add column operation
  def add_column_using_tmp_table(table_name, column_name, column_type, **options)
    with_tmp_table(table_name) do |tmp_table_name|
      add_column tmp_table_name, column_name, column_type, **options
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.message.include?('Duplicate column name')
    end
  end

  # Remove column operation
  def remove_column_using_tmp_table(table_name, column_name)
    with_tmp_table(table_name) do |tmp_table_name|
      remove_column tmp_table_name, column_name
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.message.include?('check that column/key exists')
    end
  end

  # Rename column operation
  def rename_column_using_tmp_table(table_name, column_name, new_column_name)
    with_tmp_table(table_name) { |tmp_table_name| rename_column(tmp_table_name, column_name, new_column_name) }
  end

  # Add index operation
  def add_index_using_tmp_table(table_name, column_name, options = {})
    # generate the index name using the original table name if no name provided
    options[:name] = index_name(table_name, column: Array(column_name)) if options[:name].nil?
    with_tmp_table(table_name) { |tmp_table_name| add_index(tmp_table_name, column_name, **options) }
  end

  # Remove index operation
  def remove_index_using_tmp_table(table_name, options = {})
    with_tmp_table(table_name) do |tmp_table_name|
      remove_index(tmp_table_name, name: index_name(table_name, options))
    end
  end

  private

  def with_tmp_table(table_name)
    raise ArgumentError 'block expected' unless block_given?

    unless ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      puts "Warning: Unsupported connection adapter '#{ActiveRecord::Base.connection.class.name}' for MySQLBigTableMigrationHelper."
      puts '         Methods will still be executed, but without using a temp table.'
      yield table_name
      return
    end

    table_name = table_name.to_s
    new_table_name = 'tmp_new_' + table_name
    old_table_name = 'tmp_old_' + table_name

    proceed = false

    begin
      puts "Creating temporary table #{new_table_name} like #{table_name}..."
      ActiveRecord::Base.connection.execute("CREATE TABLE #{new_table_name} LIKE #{table_name}")

      # yield the temporary table name to the block, which should alter the table using standard migration methods
      yield new_table_name

      # get column names to copy *after* yielding to block - could drop a column from new table
      # note: do not get column names using the column_names method, we need to make sure we avoid obtaining a cached array of column names
      existing_column_names = []
      # see ruby mysql docs for more info
      ActiveRecord::Base.connection.execute("DESCRIBE #{table_name}", as: :hash).each do |row|
        existing_column_names << row[0]
      end
      new_column_names = []
      ActiveRecord::Base.connection.execute("DESCRIBE #{new_table_name}").each do |row|
        new_column_names << row[0]
      end

      # columns to copy is intersection of existing and new - i.e. only columns in both tables
      columns_to_copy = '`' + (existing_column_names & new_column_names).join('`, `') + '`'

      timestamp_before_migration = ActiveRecord::Base.connection.execute('SELECT CURRENT_TIMESTAMP').first[0] # Time object
      puts "Timestamp before migration: #{timestamp_before_migration.to_s(:db)}"

      number_of_days = 30

      start_at = ActiveRecord::Base.connection.execute("SELECT MIN(updated_at) FROM #{table_name}").first[0].beginning_of_day
      puts "Inserting into temporary table in batches of #{number_of_days} days..."
      while start_at <= timestamp_before_migration
        end_at = (start_at + number_of_days.days).end_of_day
        puts "Processing rows where updated_at between #{start_at.to_s(:db)} and #{end_at.to_s(:db)}"
        ActiveRecord::Base.connection.execute("REPLACE INTO #{new_table_name} (#{columns_to_copy}) SELECT #{columns_to_copy} FROM #{table_name} WHERE updated_at >= '#{start_at.to_s(:db)}' AND updated_at < '#{end_at.to_s(:db)}'")
        start_at = (end_at + 1.day).beginning_of_day
      end
      proceed = true
    rescue Exception => e
      drop_table new_table_name
      raise
    end

    if proceed
      puts 'Replacing source table with temporary table...'
      rename_table table_name, old_table_name
      rename_table new_table_name, table_name

      puts 'Cleaning up, checking for rows created/updated during migration, dropping old table...'
      begin
        ActiveRecord::Base.connection.execute("LOCK TABLES #{table_name} WRITE, #{old_table_name} READ")
        recently_created_or_updated_conditions = existing_column_names.include?(:updated_at) ? "updated_at > '#{timestamp_before_migration}'" : nil
        if recently_created_or_updated_conditions
          ActiveRecord::Base.connection.execute("REPLACE INTO #{table_name} (#{columns_to_copy}) SELECT #{columns_to_copy} FROM #{old_table_name} WHERE #{recently_created_or_updated_conditions}")
        end
      rescue Exception => e
        puts 'Failed to lock tables and do final cleanup. This may not be anything to worry about, especially on an infrequently used table.'
        puts 'ERROR MESSAGE: ' + e.message
      ensure
        ActiveRecord::Base.connection.execute('UNLOCK TABLES')
      end
      drop_table old_table_name
    end
  end
end
