def stop_kinesis
  system 'sudo service kinesis_consumer_clicks stop'
  system 'sudo service kinesis_consumer_conversions stop'
  system 'sudo service kinesis_consumer_redshift stop'
  system 'sudo service kinesis_consumer_partitions stop'
  system 'sudo service kinesis_consumer_others stop'
end

namespace :kinesis do
  namespace :consume do
    desc 'Consume kinesis stream to process missing click-related data'
    task :missing_clicks, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :missing_clicks)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :missing_clicks)
      end
    end

    task :custom_conversions, [:options] => :environment do |_t, _args|
      conversion_processor = DotOne::Kinesis::Processor.new(task_group: :conversions, custom: true)

      conversion_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :conversions)
      end
    end

    desc 'Run custom'
    task :all, [:options] => :environment do |_t, _args|
      click_processor = DotOne::Kinesis::Processor.new(task_group: :clicks, custom: true)

      click_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :clicks)
      end

      conversion_processor = DotOne::Kinesis::Processor.new(task_group: :conversions, custom: true)

      conversion_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :conversions)
      end

      redshift_processor = DotOne::Kinesis::Processor.new(task_group: :redshift, custom: true)

      redshift_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :redshift)
      end

      partition_processor = DotOne::Kinesis::Processor.new(task_group: :partitions, custom: true)

      partition_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :partitions)
      end

      others_processor = DotOne::Kinesis::Processor.new(task_group: :others, custom: true)

      others_processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :others)
      end
    end

    desc 'Consume kinesis stream to process click-related data'
    task :clicks, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :clicks)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :clicks)
      end
    end

    desc 'Consume kinesis stream to process conversion-related data'
    task :conversions, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :conversions)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :conversions)
      end
    end

    desc 'Consume kinesis stream to mirror data to redshift'
    task :redshift, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :redshift)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :redshift)
      end
    end

    desc 'Consume kinesis stream to process data partitions'
    task :partitions, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :partitions)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :partitions)
      end
    end

    desc 'Consume kinesis stream to process conversion-related data'
    task :others, [:options] => :environment do |_t, _args|
      processor = DotOne::Kinesis::Processor.new(task_group: :others)

      processor.on_process do |kinesis_data|
        kinesis_hash = DotOne::Kinesis::Client.from_kinesis_data(kinesis_data)
        DotOne::Kinesis::Client.process_kinesis_hash(kinesis_hash, :others)
      end
    end
  end

  task restart: :environment do
    raise 'Not the correct server type.' unless SERVER_TYPE == 'SUPPORT'

    system 'sudo service kinesis_consumer_clicks restart'
    system 'sudo service kinesis_consumer_conversions restart'
    system 'sudo service kinesis_consumer_redshift restart'
    system 'sudo service kinesis_consumer_partitions restart'
    system 'sudo service kinesis_consumer_others restart'
  end

  task stop: :environment do
    stop_kinesis
  end
end
