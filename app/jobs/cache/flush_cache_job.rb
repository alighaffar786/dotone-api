class Cache::FlushCacheJob < EntityManagementJob
  def perform(klass, ids, action = nil)
    klass.constantize.flush_cache(action: action, ids: [ids].flatten)
  end
end
