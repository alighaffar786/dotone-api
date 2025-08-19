# frozen_string_literal: true

class ClientApis::ProductApi::PullJob < ApiPullJob
  def perform(id = nil)
    if id
      product_api = ClientApi.find_by(id: id)
      return unless product_api&.active?

      PRODUCT_IMPORT_LOGGER.warn "[#{Time.now}] Processing Product API: #{product_api.id} - #{product_api.name}: "
      begin
        product_api.import_products
        PRODUCT_IMPORT_LOGGER.warn "[#{Time.now}] Completed Product API: #{product_api.id} - #{product_api.name}: "
      rescue StandardError => e
        Sentry.capture_exception(e)
        PRODUCT_IMPORT_LOGGER.error(e)
      ensure
        product_api.mark_as_import_finished
      end
    else
      ClientApi.product_api.active.pluck(:id).each do |id|
        self.class.perform_later(id)
      end
    end
  end
end
