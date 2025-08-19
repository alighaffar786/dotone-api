class DotOne::Utils::Rescuer
    ##
    # Helper to prevent deadlocks from
    # continuing the process. At least
    # retry it first before throwing error
    def self.no_deadlock(num_of_tries = 3, sleep_time = 30)
      retries = 0
      begin
        yield
      rescue ActiveRecord::StatementInvalid => e
        raise e unless e.message =~ /Deadlock found when trying to get lock/ || e.message =~ /Lock wait timeout/

        retries += 1
        raise e if retries > num_of_tries ## max 3 retries by default

        sleep sleep_time
        retry
      end
    end

    ##
    # Helper to prevent Redshift not
    # interrupting the rest of code
    # before at least try re-querying
    def self.no_pg_query_cancelled
      retries = 0
      begin
        yield
      rescue ActiveRecord::StatementInvalid => e
        raise e unless e.message =~ /Query cancelled/

        retries += 1
        raise e if retries > 3  ## max 3 retries

        sleep 1
        retry
      end
    end
end
