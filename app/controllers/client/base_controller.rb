class Client::BaseController < ActionController::Base
  layout 'application'

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def current_skin
    @current_skin ||= SkinMap.with_hostname(request.host).first
  end
end
