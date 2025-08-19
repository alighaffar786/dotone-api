# Module that handles any current setup
module CurrentHandler
  protected

  def current_language
    @current_language ||= (params[:locale].presence && Language.cached_find_by(locale: params[:locale])) ||
      current_user.try(:cached_language) ||
      Language.platform
  end

  def current_currency
    @current_currency ||= (params[:currency].presence && Currency.cached_find_by(code: params[:currency])) ||
      current_user.try(:cached_currency) ||
      Currency.platform
  end

  def current_time_zone
    @current_time_zone ||= (params[:time_zone].presence && TimeZone.cached_find_by(gmt: params[:time_zone])) ||
      current_user.try(:cached_time_zone) ||
      TimeZone.platform
  end

  def current_locale
    @current_locale ||= params[:locale].presence || current_language.locale
  end

  def current_currency_code
    @current_currency_code ||= params[:currency].presence || current_currency.code
  end

  def current_gmt
    @current_gmt ||= params[:time_zone].presence || current_time_zone.gmt
  end

  def current_search
    @current_search ||= params[:search].presence
  end

  def current_page
    @current_page ||= (params[:page] || DEFAULT_PAGE).to_i
  end

  def current_per_page
    @current_per_page ||= (params[:per_page] || DEFAULT_PER_PAGE).to_i
  end

  def current_t_locale
    @current_t_locale ||= params[:t_locale]
  end

  def current_download_format
    @current_download_format ||= params[:download_format].presence || :csv
  end

  def current_columns
    @current_columns ||= if params[:columns].is_a?(Array)
      params[:columns].to_a.map(&:to_sym)
    else
      params[:columns].to_s.split(',').map(&:to_sym)
    end
  end

  def current_options
    {
      locale: current_locale,
      currency_code: current_currency_code,
      time_zone: current_time_zone,
    }
  end
end
