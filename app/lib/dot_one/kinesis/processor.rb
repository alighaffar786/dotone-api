require 'fileutils'

class DotOne::Kinesis::Processor
  attr_reader :client, :stream_name, :task_group, :key

  def initialize(options = {})
    @client = Aws::Kinesis::Client.new(region: kinesis_region)
    @task_group = (options[:task_group] || :others)&.to_sym
    @key = Time.now.to_i if options[:custom]

    @stream_name = Rails.env.production? ? [DotOne::Kinesis::STREAM_NAMES[@task_group], Rails.env].join('_') : "dotone_#{Rails.env}"

    raise "[#{Time.now.utc}][STREAM NAME NOT FOUND]: Please enter stream name for #{@task_group}" unless @stream_name

    custom_get_record_limit = @task_group && ENV.fetch("KINESIS_#{@task_group.upcase}_GET_RECORD_LIMIT", nil)

    @kinesis_get_record_limit = if custom_get_record_limit
      custom_get_record_limit.to_i
    else
      500
    end
  end

  def put(task_name, entity, options = {}, *args)
    return false if task_name.blank? || entity.blank?
    return false unless entity.respond_to?(:to_kinesis_blob)

    @attempts ||= 0

    entity = if entity.respond_to?(:persisted?) && entity.persisted?
      entity.reload
    else
      entity
    end

    raise "#{task_name} #{entity}" if entity.respond_to?(:id) && entity.id.blank?

    r = client.put_record(
      stream_name: stream_name,
      data: entity.to_kinesis_blob(task_name, *args),
      partition_key: '1',
    )

    puts "Saving #{r.sequence_number}" if options[:console] == true
    true
  rescue Exception => e
    raise e if Rails.env.development?

    if [Aws::Kinesis::Errors::InternalFailure, Aws::Kinesis::Errors::Http503Error].include?(e.class) && @attempts < 10
      sleep 2
      @attempts += 1
      KINESIS_LOGGER.info "[DotOne::Kinesis::Processor#put]: retrying attemps #{@attempts}..."
      retry
    else
      @attempts = nil
      Sentry.capture_exception(e)
      error_message = e.message
      backtrace = e.backtrace.join("\r\n")
      KINESIS_LOGGER.error "[DotOne::Kinesis::Processor#put]: #{error_message}"
      KINESIS_LOGGER.error backtrace

      resource = entity.respond_to?(:attributes) ? [entity.class.to_s, entity.attributes] : [entity.to_s]
      Kinesis::PutJob.perform_later(task_group.to_s, task_name.to_s, resource, options, *args)

      if options[:console] == true
        puts error_message
        puts backtrace
      end
    end
  end

  def on_process
    @shutdown = false
    shutting_down = -> {
      puts 'Shutting down...'
      @shutdown = true
    }
    Signal.trap('TERM') { shutting_down.call }
    Signal.trap('INT')  { shutting_down.call }

    shard = client
      .describe_stream(stream_name: stream_name)
      .stream_description
      .shards
      .last

    last_sequence = get_last_sequence

    last_sequence = shard.sequence_number_range.starting_sequence_number if last_sequence.blank?

    KINESIS_LOGGER.warn "Continuing #{stream_name} from Sequence Number: #{last_sequence}..."

    begin
      response = client.get_shard_iterator(
        stream_name: stream_name,
        shard_id: shard.shard_id,
        shard_iterator_type: 'AT_SEQUENCE_NUMBER',
        starting_sequence_number: last_sequence,
      )

      next_shard_iterator = response.shard_iterator

      until @shutdown
        sleep(1)

        response = client.get_records(
          shard_iterator: next_shard_iterator,
          limit: @kinesis_get_record_limit,
        )

        last_sequence = response.records[0]&.sequence_number

        puts "Last Sequence: #{last_sequence}"
        puts "Looping thru #{response.records.size} records"

        yield(response.records)

        set_last_sequence(last_sequence)

        next_shard_iterator = response.next_shard_iterator
        break unless next_shard_iterator.present?
      end
    rescue PG::ConnectionBad => e
      KINESIS_LOGGER.error e.message
      KINESIS_LOGGER.info "Retrying #{stream_name} in 30 minutes..."
      sleep 30 * 60
      retry
    rescue Exception => e
      Sentry.capture_exception(e)
      error_message = e.message
      backtrace = e.backtrace.join("\r\n")
      KINESIS_LOGGER.error "[#{Time.now.utc}][DotOne::Kinesis::Processor#on_process]: #{error_message}"
      KINESIS_LOGGER.error backtrace
      raise e
    end
  end

  private

  def last_sequence_path
    Rails.root.join("log/kinesis/#{task_group}")
  end

  def get_last_sequence
    seq = DotOne::Cache.fetch(cache_key)
    seq = ENV["last_#{task_group}".upcase] if seq.blank? && key.present?
    seq
  end

  def set_last_sequence(data, cleanup = false)
    return if data.blank? && !cleanup

    dir = File.dirname(last_sequence_path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    File.write(last_sequence_path, "#{Time.now.to_s(:db)} #{data}")

    Rails.cache.write(cache_key, data, { expires_in: 99.days })
  end

  def cleanup_last_sequence
    set_last_sequence('', true)
  end

  def kinesis_region
    ENV.fetch('KINESIS_REGION', 'us-east-1')
  end

  def cache_key
    [kinesis_region, stream_name, task_group, key, 'last_sequence'].compact.join('-')
  end
end
