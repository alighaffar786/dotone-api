# frozen_string_literal: true

class ClientApis::OrderApi::CjFinalizeJob < ApiPullJob
  def perform(options = {})
    ORDER_FINALIZER_LOGGER.info "[#{Time.now}] Starting..."

    start_at = options[:start_at]
    end_at = options[:end_at]
    converted_at = options[:converted_at]
    ids = options[:ids] || []
    ids = (ids.is_a?(String) ? ids.split(/,|\n/) : ids).map(&:to_s)

    request_data = {
      start_at: start_at,
      end_at: end_at,
      converted_at: converted_at,
      ids: ids,
    }

    return if ids.blank?

    JobStatusCheck.watch(JobStatusCheck.job_type_cj_finalize_job, request_data) do
      clear_cache

      api = ClientApi.order_api.find_by(name: 'OrderApi::Cj')
      client = api.client(start_at: start_at, end_at: end_at, no_modification_on_final_status: true, finalize: true)
      client.commission_ids_to_finalize = ids

      client.to_items.each do |x|
        item = client.get_item(x)
        copy_stat = item.copy_stat&.reload

        next if copy_stat.blank?
        next if copy_stat.considered_approved? || copy_stat.considered_rejected?

        begin
          item.to_stat(converted_at: converted_at)
        rescue StandardError => e
          ORDER_FINALIZER_LOGGER.info "[#{Time.now}] [Order Number: #{item.order_number}] Error: #{e.message}"
          next
        end
      end

      clear_cache
    end

    ORDER_FINALIZER_LOGGER.info "[#{Time.now}] Done."
  end

  def clear_cache
    DotOne::ApiClient::OrderApi::BaseClient::CACHE_STORE.clear
  end
end
