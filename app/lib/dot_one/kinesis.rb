module DotOne::Kinesis
  STREAM_NAMES = {
    missing_clicks: ENV.fetch('KINESIS_STREAM_MISSING_CLICKS'),
    clicks: ENV.fetch('KINESIS_STREAM_CLICKS'),
    conversions: ENV.fetch('KINESIS_STREAM_CONVERSIONS'),
    others: ENV.fetch('KINESIS_STREAM_OTHERS'),
    partitions: ENV.fetch('KINESIS_STREAM_PARTITIONS'),
    redshift: ENV.fetch('KINESIS_STREAM_REDSHIFT'),
  }.freeze

  TASK_ATTACH_SIBLING = 'attach_sibling'
  TASK_DELAYED_TOUCH = 'delayed_touch'
  TASK_PARTITION_DELAYED_TOUCH = 'partition_delayed_touch'
  TASK_SAVE_TRACKING_DOMAIN_STAT = 'save_tracking_domain_stat'
  TASK_SAVE_POSTBACK = 'save_postback'
  TASK_PARTITION_TABLES = 'partition_tables'
  TASK_REDSHIFT = 'redshift'
  TASK_SAVE_CLICK = 'save_click'
  TASK_PROCESS_CONVERSION = 'process_conversion'
end
