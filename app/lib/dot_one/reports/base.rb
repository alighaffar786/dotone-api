class DotOne::Reports::Base
  attr_accessor :time_zone, :currency_code

  def initialize(params = {})
    @time_zone = params[:time_zone].presence || TimeZone.current
    @currency_code = params[:currency_code].presence || Currency.current_code
  end

  def generate(&block)
    return {} unless block_given?

    DotOne::Cache.fetch(cache_key_name, expires_in: 30.minutes, &block)
  end

  protected

  def cache_key_name(*keys)
    DotOne::Utils.to_cache_key([], self.class.name, *keys)
  end
end
