module DotOne::ApiClient::OrderApi::Udn
  class Client < DotOne::ApiClient::OrderApi::BaseClient
    DAYS_TO_THE_PAST = 60
    DATE_FORMAT = '%Y%m%d%H%M'

    attr_accessor :start_at, :end_at, :stat, :api_key, :tag, :host

    # Temporary use due to production server
    # fails to access json data directly. This
    # variable is to hold json response obtained
    # separately
    attr_accessor :json_data

    def initialize(options = {})
      super(options)
      @start_at = Time.parse(options[:start_at]).strftime(DATE_FORMAT) rescue nil
      @start_at = (Date.today - DAYS_TO_THE_PAST.day).strftime(DATE_FORMAT) if @start_at.blank?

      @end_at = Time.parse(options[:end_at]).strftime(DATE_FORMAT) rescue nil
      @end_at = Date.today.strftime(DATE_FORMAT) if @end_at.blank?

      @api_key = options[:key]
      @tag = options[:auth_token]
      @host = options[:host]
      @missing_click_with_order_number = true
    end

    def request_url
      # test details
      # checksum_key = 'udnshoppingtest'
      # domain = "uat-shopping56.udn.com"
      # port = 443

      # live details
      checksum_key = @api_key
      domain = @host
      port = 443

      # timestamp + 8.hour (GMT+8 : Taiwan Time)
      timestamp = (Time.now.utc + 8.hour).strftime("#{DATE_FORMAT}%S")
      md5 = Digest::MD5.new
      md5 << checksum_key
      md5 << timestamp

      queries = {
        tag: @tag,
        start_time: @start_at,
        end_time: @end_at,
        t: timestamp,
        checksum: md5.hexdigest,
      }

      URI::HTTPS.build({
        host: domain,
        path: '/spm/adm/ord/Cm1o09.do',
        port: port,
        query: queries.to_param,
      })
    end

    # Method to convert response to items
    def to_items
      to_process = @json_data || to_json rescue nil

      return [] if to_process.blank?

      iterate_and_capture_missing_clicks(to_process) do |record|
        item = DotOne::ApiClient::OrderApi::Udn::Item.new(record)
        item.log_it!
        @item_keys << store_it!(item)
      end

      @item_keys
    end
  end
end
