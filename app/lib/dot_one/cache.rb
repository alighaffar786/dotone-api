class DotOne::Cache
  def self.domain(request_domain)
    cache_key = DotOne::Utils.to_global_cache_key([], 'domain', request_domain)

    fetch(cache_key, expires_in: CACHE_DURATION) do
      DotOne::Setup.tracking_host == request_domain ||
        AlternativeDomain.with_domain(request_domain).exists?
    end
  end

  def self.fetch(key, options = nil, &block)
    if ENV['CACHE_WRITE_MODE'] == '1'
      Rails.cache.read(key) || Rails.cache.write(key, block.call, options) && block.call
    elsif DotOne::Setup.db_on?
      Rails.cache.fetch(key, options, &block)
    else
      Rails.cache.read(key)
    end
  end
end
