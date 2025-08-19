module DotOne::Kinesis::Streamable
  extend ActiveSupport::Concern

  # Generate blob to put into stream
  # data_blob in hash will be in this format:
  # { wl_company_id => { :clicks => 1, :conversions => 1, :approval => ... } }
  def to_kinesis_blob(task_name, *args)
    return unless respond_to?(:attributes)

    hash_to_dump = {}

    self.class.columns.each do |col|
      hash_to_dump[col.name] = if col.sql_type == 'json'
        attributes[col.name]&.to_json
      else
        attributes[col.name]
      end
    end

    hash_to_dump = hash_to_dump.merge({
      _wl_company_id: DotOne::Setup.wl_id.to_s,
      _klass_name: self.class.name,
      _task_name: task_name,
      _args: args,
    })

    MultiJson.dump(hash_to_dump)
  end

  def to_kinesis(task_name, options = {}, *args)
    return false if task_name.blank?
    return false unless DotOne::Kinesis::Client.is_kinesis_on?

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
end
