# frozen_string_literal: true

class ClientApis::OrderApi::PullJob < ApiPullJob
  def perform(id = nil, options = {})
    if JobStatusCheck.cj_finalize_in_progress?
      self.class.set(wait: 10.minutes).perform_later(id, options)
      return
    end

    if id
      order_api = ClientApi.find_by(id: id)
      return unless order_api&.active?

      ORDER_API_PULL_LOGGER.warn "[#{Time.now}] Processing Order API: #{order_api.id} - #{order_api.name}: "
      begin
        order_api.import_orders(options)
        ORDER_API_PULL_LOGGER.warn "[#{Time.now}] Completed Order API: #{order_api.id} - #{order_api.name}: "
      rescue StandardError => e
        Sentry.capture_exception(e)
        ORDER_API_PULL_LOGGER.error(e)
      ensure
        order_api.mark_as_import_finished
      end
    else
      ClientApi.order_api.active.pluck(:id).each do |id|
        self.class.perform_later(id, options)
      end
    end
  end
end
