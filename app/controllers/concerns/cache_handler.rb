module CacheHandler
  protected

  def fetch_cached(key_entities, *keys, **options, &block)
    cache_key = DotOne::Utils.to_cache_key(key_entities, *keys)

    DotOne::Cache.fetch(cache_key, { expires_in: CACHE_DURATION, **options }, &block)
  end

  def fetch_cached_on_controller(*keys, **options, &block)
    cache_key = DotOne::Utils.to_cache_key([], *keys, params[:controller], params[:action], params[:billing_region])

    DotOne::Cache.fetch(cache_key, { expires_in: CACHE_DURATION, **options }, &block)
  end

  def fetch_global_cached_on_controller(&block)
    cache_key = [params[:controller], params[:action]].join('/')

    DotOne::Cache.fetch(cache_key, { expires_in: 1.year }, &block)
  end
end
