# Cron loggers

# Stat related
STAT_SYNC_LOGGER = Logger.new("#{Rails.root}/log/stat_sync.log")
STAT_SYNC_ORDER_NUMBER_LOGGER = Logger.new("#{Rails.root}/log/stat_order_number_sync.log")
STAT_SYNC_CLICK_ID_LOGGER  = Logger.new("#{Rails.root}/log/stat_click_id_sync.log")
STAT_SYNC_COPY_STAT_MISSING_LOGGER = Logger.new("#{Rails.root}/log/stat_copy_stat_missing_logger.log")
STAT_IMPORT_LOGGER = Logger.new("#{Rails.root}/log/stat_import_error.log")
STAT_DUPLICATE_CLEANUP_LOGGER = Logger.new("#{Rails.root}/log/stat_duplicate_cleanup.log")
PAST_DUE_LOGGER = Logger.new("#{Rails.root}/log/past_dues.log")
STATS_ARCHIVER_LOGGER = Logger.new("#{Rails.root}/log/stat_archive.log")
KINESIS_CONVERSION_LOGGER = Logger.new("#{Rails.root}/log/kinesis_conversions.log")
KINESIS_STAT_LOGGER = Logger.new("#{Rails.root}/log/kinesis_affiliate_stats.log")
KINESIS_MISSING_STAT_LOGGER = Logger.new("#{Rails.root}/log/kinesis_missing_affiliate_stats.log")
KINESIS_LOGGER = Logger.new("#{Rails.root}/log/kinesis.log")
KINESIS_STATE_LOGGER = Logger.new("#{Rails.root}/log/kinesis_state.log")
DELAYED_CONVERSION_LOGGER = Logger.new("#{Rails.root}/log/tracking/delayed_conversion.log")

NETWORK_RAKE_LOGGER = Logger.new("#{Rails.root}/log/network_rakes.log")

# Order related
ORDER_API_PULL_LOGGER = Logger.new("#{Rails.root}/log/order_api_pull.log")
ORDER_API_CLICK_STAT_MISSING_LOGGER = Logger.new("#{Rails.root}/log/order_api_click_stat_missing.log")
ORDER_CLEANUP_LOGGER = Logger.new("#{Rails.root}/log/order_cleanup.log")
ORDER_FINALIZER_LOGGER = Logger.new("#{Rails.root}/log/order_finalizer.log")

PRODUCT_IMPORT_LOGGER = Logger.new("#{Rails.root}/log/product_import.log")

CDN_LOGGER = Logger.new("#{Rails.root}/log/process_cdn.log")

MISSING_ORDER_LOGGER = Logger.new("#{Rails.root}/log/missing_order.log")
