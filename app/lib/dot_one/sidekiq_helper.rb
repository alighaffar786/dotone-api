module DotOne::SidekiqHelper
  extend ActiveSupport::Concern
  extend self

  class Scheduled
    class << self
      def set
        Sidekiq::ScheduledSet.new
      end

      def exists?(job_class, *args)
        find_by(job_class, *args).present?
      end

      def find_by(job_class, *args)
        set.find do |job|
          job.args.dig(0, 'job_class') == job_class && job.args.dig(0, 'arguments') == args
        end
      end

      def delete_by(job_class, *args)
        job = find_by(job_class, *args)
        job.delete if job.present?
      end

      def filter_by(job_class, *args, **options)
        arg_idx = options[:arg_idx]

        set.select do |job|
          job.args.dig(0, 'job_class') == job_class &&
          (arg_idx.present? ? job.args.dig(0, 'arguments', arg_idx) == args[arg_idx] : job.args.dig(0, 'arguments') == args)
        end
      end

      def delete_all_by(job_class, *args, **options)
        filter_by(job_class, *args, **options).each(&:delete)
      end

      def run_unique_by(job_class, *args)
        job_class.constantize.perform_later(*args) unless exists?(job_class, *args)
      end
    end
  end

  class Enqueued
    class << self

      def get_queue(queue_name)
        Sidekiq::Queue.new(queue_name)
      end

      def find_by(queue_name, job_class, *args)
        queue = get_queue(queue_name)

        queue.find do |job|
          job.args.dig(0,'job_class') == job_class && (args.blank? || job.args.dig(0, 'arguments') == args)
        end
      end

      def filter_by(queue_name, job_class, *args)
        queue = get_queue(queue_name)

        queue.select do |job|
          job.args.dig(0,'job_class') == job_class && (args.blank? || job.args.dig(0, 'arguments') == args)
        end
      end

      def exists?(queue_name, job_class, *args)
        find_by(queue_name, job_class, *args).present?
      end
    end
  end

  class Worker
    class << self
      def set
        Sidekiq::WorkSet.new
      end

      def payloads
        set.map { |x| x.dig(2, 'payload') }
      end

      def find_by(queue_name, job_class, *args)
        payloads.find do |payload|
          payload.dig('args', 0, 'job_class') == job_class &&
          (queue_name.blank? || payload.dig('args', 0, 'queue_name') == queue_name) &&
          (args.blank? || payload.dig('args', 0, 'arguments') == args)
        end
      end

      def filter_by(queue_name, job_class, *args)
        payloads.select do |payload|
          payload.dig('args', 0, 'job_class') == job_class &&
          (queue_name.blank? || payload.dig('args', 0, 'queue_name') == queue_name) &&
          (args.blank? || payload.dig('args', 0, 'arguments') == args)
        end
      end

      def exists?(queue_name, job_class, *args)
        find_by(queue_name, job_class, *args).present?
      end
    end
  end

  def scheduled?(job_class, *args)
    Scheduled.exists?(job_class, *args)
  end

  def delete_scheduled_by(job_class, *args)
    Scheduled.delete_by(job_class, *args)
  end

  def delete_all_scheduled_by(job_class, *args)
    Scheduled.delete_all_by(job_class, *args)
  end

  def run_unique_scheduled_by(job_class, *args)
    Scheduled.run_unique_by(job_class, *args)
  end

  def exists_any?(queue_name, job_class, *args)
    Worker.exists?(queue_name, job_class, *args) ||
    Enqueued.exists?(queue_name, job_class, *args)
  end

  def count_all(queue_name, job_class, *args)
    Worker.filter_by(queue_name, job_class).size +
    Enqueued.filter_by(queue_name, job_class).size
  end
end
