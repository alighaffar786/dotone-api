class Kinesis::PutJob < KinesisJob
  def perform(task_group, task_name, resource, options = {}, *args)
    klass, attrs = resource
    klass = klass.constantize

    entity =
      if klass.present? && attrs.present?
        if attrs['id'].present?
          klass.find_by(id: attrs['id']) || klass.new(attrs)
        else
          klass.new(attrs)
        end
      else
        klass
      end

    processor = DotOne::Kinesis::Processor.new(task_group: task_group.to_sym)
    processor.put(task_name.to_sym, entity, options, *args)
  end
end
