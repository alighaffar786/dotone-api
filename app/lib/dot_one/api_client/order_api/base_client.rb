module DotOne::ApiClient::OrderApi
  class BaseClient
    include DotOne::ApiClient::Shared

    attr_accessor :item_keys, :auto_seed, :client_api_id, :missing_click_csv, :client_api,
      :missing_click_with_order_number

    # Mark current client to finalize conversions
    # during processing
    attr_accessor :finalize

    # Mark current client to ignore final state
    # and process conversion as if it is not final
    attr_accessor :no_modification_on_final_status

    CACHE_EXPIRATION = {
      expires_in: 2.days,
    }

    CACHE_STORE = ActiveSupport::Cache::FileStore.new("#{Rails.root}/tmp/cache/api-pull/#{Date.today}")

    def initialize(options = {})
      @client_api_id = options[:id]
      @client_api = ClientApi.find(client_api_id)
      @item_keys = []
      @auto_seed = Time.now.to_i
      @finalize = options[:finalize] || false
      @no_modification_on_final_status = options[:no_modification_on_final_status].nil? ? true : options[:no_modification_on_final_status]
      @missing_clicks_csv = build_missing_clicks_csv
      @missing_clicks_count = 0
    end

    ##
    # Helper to combine related item and update its
    # total and payout
    def store_it!(item, options = {})
      raise 'Click stat is blank' if item.click_stat.blank?

      copy_stat = item.copy_stat

      if @no_modification_on_final_status && !finalize && item.order(options).present? && !item.pending?
        raise 'Order is in final state'
      elsif @no_modification_on_final_status && finalize && copy_stat && (copy_stat.considered_approved? || copy_stat.considered_rejected?)
        raise 'Order is in approved or rejected state'
      end

      # Sometimes click stat id is not the correct key to
      # use due to same order might belong to different click in case
      # of split (multi atrribution) conversions. So it is up to
      # the client to determine which key can be used to determine
      # that it is the same order
      cache_key_to_use = options[:custom_cache_key]

      cache_key_to_use = [item.click_stat.id, item.order_number] if cache_key_to_use.blank?

      cache_key_to_use = [cache_key_to_use].flatten

      key = ([@auto_seed] + cache_key_to_use).join('-')

      cache_key = DotOne::Utils::Encryptor.hexdigest(key)

      existing_item = CACHE_STORE.fetch(cache_key)

      if existing_item.blank?
        CACHE_STORE.write(cache_key, item, CACHE_EXPIRATION)
      else
        existing_item.total += item.total
        existing_item.true_pay += item.true_pay

        # TODO: When we are ready for multi-level attribution
        # we might need to modify this. For now, use the latest click stat
        # since we are still operating on Last Click attribution
        existing_item.click_stat = item.click_stat

        CACHE_STORE.write(cache_key, existing_item, CACHE_EXPIRATION)
      end

      cache_key
    end

    def get_item(item_key)
      item = CACHE_STORE.fetch(item_key)
      item.no_modification_on_final_status = no_modification_on_final_status
      item
    end

    def each_item
      to_iterate = @item_keys.present? ? @item_keys : to_items

      to_iterate.each do |item_key|
        item = get_item(item_key)
        yield(item)
      end

      if @missing_clicks_count > 0
        upload = Upload.new(
          file: @missing_clicks_csv,
          descriptions: "#{@missing_clicks_count} Missing Clicks",
          uploaded_by: "ClientApi: #{client_api.id}:#{client_api.name}",
          status: Upload.status_ready,
        )
        upload.save(validate: false)
      end
    end

    def build_missing_clicks_csv
      file = Tempfile.new(["missing_click_client_id_#{client_api_id}", '.csv'])
      CSV.open(file, 'w', headers: true, encoding: 'bom|utf-8') do |csv|
        headers = ['transaction_id', 'advertiser_id']
        headers << 'order_number' if @missing_click_with_order_number
        csv << headers
      end
      file
    end

    def capture_missing_clicks(error)
      @missing_clicks_count += 1
      CSV.open(@missing_clicks_csv, 'a', encoding: 'bom|utf-8') do |csv|
        values = [error.click_id, client_api.owner.id]
        values << error.order_number if @missing_click_with_order_number
        csv << values
      end
    end

    def iterate_and_capture_missing_clicks(records)
      records.each do |record|
        yield(record)
      rescue Exception => e
        capture_missing_clicks(e) if e.class == DotOne::Errors::AffiliateStatNotFoundError
        log_error!(e)
        next
      end
    end
  end
end
