require 'multi_json'

##
# Class to take care of kinesis interaction
# between the receiver and AWS Kinesis
class DotOne::Kinesis::Client
  def self.from_kinesis_data(kinesis_data)
    kinesis_hash = {}

    # Collecting and grouping records of the same wl_company_id
    kinesis_data.map(&:data).each do |record|
      data_hash = MultiJson.load(record)

      wl_company_id = data_hash['_wl_company_id']
      task_name = data_hash['_task_name']
      args = data_hash.delete('_args')

      kinesis_hash[wl_company_id] ||= {}
      kinesis_hash[wl_company_id][task_name] ||= [] if task_name.present?

      sanitized_data = data_hash.except('_wl_company_id', '_klass_name', '_task_name')

      next unless sanitized_data

      kinesis_hash[wl_company_id][task_name] << {
        data: sanitized_data,
        args: args,
      }
    end

    kinesis_hash
  end

  # Generate blob to put into stream
  # data_blob in hash will be in this format:
  # { wl_company_id => { :clicks => 1, :conversions => 1, :approval => ... } }
  def self.to_kinesis_blob(task_name, *args)
    hash_to_dump = {
      _wl_company_id: DotOne::Setup.wl_id.to_s,
      _klass_name: AffiliateStat.name,
      _task_name: task_name,
      _args: args,
    }

    MultiJson.dump(hash_to_dump)
  end

  def self.to_kinesis(task_name, options = {}, *args)
    return if task_name.blank?
    return unless is_kinesis_on?

    if task_name == DotOne::Kinesis::TASK_REDSHIFT
      DotOne::Kinesis::Processor.new(task_group: :redshift).put(task_name, self, options, *args)
      DotOne::Kinesis::Processor.new(task_group: :partitions).put(DotOne::Kinesis::TASK_PARTITION_TABLES, self, options, *args)
    elsif task_name == DotOne::Kinesis::TASK_SAVE_CLICK
      DotOne::Kinesis::Processor.new(task_group: :clicks).put(task_name, self, options, *args)
    elsif task_name == DotOne::Kinesis::TASK_PROCESS_CONVERSION
      DotOne::Kinesis::Processor.new(task_group: :conversions).put(task_name, self, options, *args)
    else
      DotOne::Kinesis::Processor.new(task_group: :others).put(task_name, self, options, *args)
    end
  end

  # Receiver needs to implement this method
  # in order to process kinesis hash datas
  def self.process_kinesis_hash(kinesis_hash, task_group)
    if task_group == :clicks
      # Save any clicks
      DotOne::Kinesis::DataOperator.kinesis_to_save_clicks(kinesis_hash)
    elsif task_group == :missing_clicks
      # Save any clicks
      DotOne::Kinesis::DataOperator.kinesis_to_save_missing_clicks(kinesis_hash)
    elsif task_group == :conversions
      # Process any conversion
      DotOne::Kinesis::DataOperator.kinesis_to_process_conversions(kinesis_hash)
    elsif task_group == :redshift
      # Save to redshift
      DotOne::Kinesis::DataOperator.kinesis_to_redshift(kinesis_hash)
    elsif task_group == :partitions
      # Save to partition tables
      DotOne::Kinesis::DataOperator.kinesis_to_partition_tables(kinesis_hash)
    elsif task_group == :others
      # Attach any sibling
      DotOne::Kinesis::DataOperator.kinesis_to_attach_sibling(kinesis_hash)
      # Process delayed touch
      DotOne::Kinesis::DataOperator.kinesis_to_delayed_touch(kinesis_hash)
      # Process partition delayed touch
      DotOne::Kinesis::DataOperator.kinesis_to_partition_delayed_touch(kinesis_hash)
      # Process tracking domain stat
      DotOne::Kinesis::DataOperator.kinesis_to_save_tracking_domain_stat(kinesis_hash)
      # Save Postback
      DotOne::Kinesis::DataOperator.kinesis_to_save_postback(kinesis_hash)
    end
  end

  def self.is_kinesis_on?
    ENV['KINESIS_STATUS'] == 'on'
  end
end
