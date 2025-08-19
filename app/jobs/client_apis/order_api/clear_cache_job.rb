class ClientApis::OrderApi::ClearCacheJob < MaintenanceJob
  def perform
    ORDER_API_PULL_LOGGER.info "[#{Time.now}] ClientApis::OrderApi::ClearCacheJob start..."

    catch_exception do
      last_week = 1.week.ago

      Dir.glob(Rails.root.join('tmp/cache/api-pull/*')).each do |entry|
        date = entry.split('/').pop.to_date

        if File.directory?(entry) && date < last_week
          ORDER_API_PULL_LOGGER.info "  [#{Time.now}] [DIR: '#{entry}'] deleted"
          FileUtils.rm_rf(entry)
        end
      rescue Date::Error
        next
      end
    end

    ORDER_API_PULL_LOGGER.info "[#{Time.now}] ClientApis::OrderApi::ClearCacheJob done..."
  end
end
