module ModelCacheable
  extend ActiveSupport::Concern

  CACHE_ACTIONS = [:find, :find_by, :max_updated_at]
  INSTANCE_CACHE_ACTIONS = [:find]
  FIND_BY_ALLOWED = [
    'Language',
    'Currency',
    'TimeZone',
    'Country',
  ]

  included do
    after_commit :queue_flush_cache
    after_touch :queue_flush_cache
  end

  module ClassMethods
    CACHE_ACTIONS.each do |action|
      define_method "cached_#{action}" do |*args|
        if action == :find_by && !class_cache_allowed?
          raise 'cached_find_by NOT ALLOWED'
        end

        return if action != :max_updated_at && args.compact_blank.blank?

        key = cache_key(action, *args)
        log_cache(:fetch, key)

        DotOne::Cache.fetch(key) do
          send(action, *args)
        rescue ActiveRecord::RecordNotFound
        end
      end
    end

    def class_cache_allowed?
      FIND_BY_ALLOWED.include?(self.name)
    end

    def instance_cache_methods
      @instance_cache_methods || []
    end

    def set_instance_cache_methods(*methods)
      @instance_cache_methods ||= []
      @instance_cache_methods |= methods.map(&:to_sym)

      methods.each do |method|
        define_method("cached_#{method}") do |*args|
          key = instance_method_cache_key(method, *args)

          if key.present?
            self.class.log_cache(:fetch, key)

            DotOne::Cache.fetch(key) do
              value = send(method, *args)
              value = value&.reload if [:aff_hash, :brand_image, :brand_image_small, :brand_image_medium, :brand_image_large].include?(method)
              value.is_a?(ActiveRecord::Relation) ? value.to_a : value
            end
          else
            send(method, *args)
          end
        end
      end
    end

    def max_updated_at
      self.maximum(:updated_at)&.to_s(:number)
    end

    def flush_cache(action: nil, ids: nil)
      unless DotOne::Setup.db_on?
        Cache::FlushCacheJob.set(wait: 1.hour).perform_later(self.name, ids, action)
        return
      end

      actions = [action].compact.presence || CACHE_ACTIONS

      cache_keys =
        actions.map do |action|
          if INSTANCE_CACHE_ACTIONS.include?(action)
            if ids.present?
              ids.map { |id| cache_key(action, id) }
            end
          elsif class_cache_allowed?
            Rails.cache.instance_variable_get(:@data).keys.select { |key| key.starts_with?("#{cache_key(action)}/") }
          elsif action == :max_updated_at
            cache_key(:max_updated_at)
          end
        end.flatten

      cache_keys.each do |cache_key|
        log_cache(:delete, cache_key)
        Rails.cache.delete(cache_key)
      end
    end

    def cache_key(*args)
      ['model', table_name, *args].flatten.compact_blank.join('/')
    end

    def log_cache(action, key)
      return if DotOne::Setup.tracking_server?
      Rails.logger.debug "[ModelCacheable] #{action}: - #{key}"
    end
  end

  def cache_key(action = nil)
    self.class.cache_key(action, id)
  end

  def instance_method_cache_key(method, *args)
    return if new_record?
    ['model', self.class.table_name, id, method, updated_at.to_s(:number), *args].flatten.compact_blank.join('/')
  end

  def flush_cache(action = nil)
    return unless DotOne::Setup.db_on?

    actions = [action].compact.presence || CACHE_ACTIONS

    actions.each do |action|
      if INSTANCE_CACHE_ACTIONS.include?(action)
        key = cache_key(action)
        self.class.log_cache(:delete, key)
        Rails.cache.delete(key)
      else
        self.class.flush_cache(action: action, ids: [id])
      end
    end
  end

  def queue_flush_cache(action = nil)
    self.class.flush_cache(action: action, ids: [id])
  rescue Exception => e
    Sentry.capture_exception(e)
    Cache::FlushCacheJob.perform_later(self.class.name, id, action)
  end
end
