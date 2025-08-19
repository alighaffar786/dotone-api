class DotOne::Stats::Archiver
  attr_accessor :year, :month, :year_month, :connection, :db_name

  def initialize(year_month_str = nil)
    default_time = (Stat.date_limit - 1.month).strftime('%Y-%m')
    @year_month = year_month_str || default_time
    @year, @month = year_month.split('-')

    @connection = Stat.connection
    @db_name = connection.current_database

    raise StandardError, 'Cannot archive stats older than 2 years' if year_month < default_time
  end

  def archive!
    STATS_ARCHIVER_LOGGER.info "[#{Time.now}]: archive start"

    unload_to_s3!(unload_impressions: true)
    unload_to_s3!

    add_spectrum_partition!
    result = delete_stats!

    STATS_ARCHIVER_LOGGER.info "[#{Time.now}]: archived completed #{result.cmd_tuples} rows"
  rescue StandardError => e
    STATS_ARCHIVER_LOGGER.error "[#{Time.now}]: archive failed #{e.message}"
    raise e
  end

  def delete_stats!
    delete_sql = <<-SQL.squish
      DELETE FROM stats
      WHERE EXTRACT(YEAR FROM recorded_at) = #{year} AND EXTRACT(MONTH FROM recorded_at) = #{month};
    SQL

    connection.execute(delete_sql)
  end

  def add_spectrum_partition!
    return if spectrum_created?(year_month, false)

    sql = <<-SQL.squish
      ALTER TABLE spectrum.stats ADD PARTITION(recorded_date='#{year_month}') LOCATION '#{s3_location}'
    SQL

    connection.execute(sql)
  end

  def unload_to_s3!(unload_impressions: false)
    return if year_month.blank?

    return if spectrum_created?(year_month, unload_impressions)

    parsed_time = Time.strptime(year_month, '%Y-%m')
    start_at = parsed_time.beginning_of_month.to_s(:db)
    end_at = parsed_time.end_of_month.to_s(:db)

    impression_conditions = unload_impressions ? ' AND impression IS NOT NULL' : ' AND impression IS NULL'
    location = s3_location + (unload_impressions ? 'impressions_' : 'clicks_')

    select_sql = <<-SQL.squish
      SELECT * FROM stats
      WHERE recorded_at >= ''#{start_at}'' AND recorded_at <= ''#{end_at}''
      #{impression_conditions}
    SQL

    sql = <<-SQL.squish
      UNLOAD ('#{select_sql}')
      TO '#{location}'
      iam_role 'arn:aws:iam::964352350895:role/ConverlySpectrumRole'
      delimiter AS '\t'
      allowoverwrite;
    SQL

    connection.execute(sql)
  end

  private

  def spectrum_created?(year_month, unload_impressions)
    path = "#{Rails.env}/#{db_name}/stats/recorded_date=#{year_month}/#{unload_impressions ? 'impressions' : 'clicks'}"
    bucket = Aws::S3::Bucket.new('converly-redshift-spectrum')

    bucket.objects(prefix: path).count > 0
  end

  def s3_location
    "s3://converly-redshift-spectrum/#{Rails.env}/#{db_name}/stats/recorded_date=#{year_month}/"
  end
end
