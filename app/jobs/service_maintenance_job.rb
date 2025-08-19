# frozen_string_literal: true

class ServiceMaintenanceJob < TrackingJob
  def perform
    services = [
      'kinesis_consumer_clicks',
      'kinesis_consumer_conversions',
      'kinesis_consumer_redshift',
      'kinesis_consumer_partitions',
      'kinesis_consumer_others',
      'process_cdn',
    ]

    services.each do |service|
      result = `sudo service #{service} status`

      next if result.match(/Active: active \(running\)/)

      system "sudo service #{service} restart"

      KINESIS_STATE_LOGGER.info "[#{Time.now}] restarted #{service} service"
      KINESIS_STATE_LOGGER.info "[#{Time.now}] status response: #{result}"

    rescue Exception => e
      Sentry.capture_exception(e)
      raise e
    end
  end
end
