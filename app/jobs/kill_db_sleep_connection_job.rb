class KillDbSleepConnectionJob < MaintenanceJob
  def perform(kill_timeout = 1200, whitelisted_ips = [])
    @kill_timeout = kill_timeout
    @whitelisted_ips = whitelisted_ips

    @connection = ActiveRecord::Base.establish_connection(:primary).connection

    @connection.execute(query_processlist).each do |row|
      id, time, query = row
      @connection.execute(query)
    end
  end

  private

  def query_processlist
    <<-SQL
      SELECT ID, TIME, concat('KILL ', ID, ';') AS query
      FROM information_schema.processlist
      WHERE
        COMMAND = 'Sleep' AND
        TIME > #{@kill_timeout}
        #{query_host}
    SQL
  end

  def query_host
    hosts = @whitelisted_ips.map { |host| "HOST NOT LIKE '#{host}%'" }.join(' AND ')

    hosts.blank? ? '' : "AND (#{hosts})"
  end
end
