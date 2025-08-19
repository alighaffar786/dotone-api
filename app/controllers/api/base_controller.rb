class Api::BaseController < ApplicationController
  include Api::ValidateHelper

  check_authorization

  before_action :add_sentry_user_context
  before_action :require_params, :store_current
  around_action :switch_locale

  def full_scope?
    @full_scope ||= params[:scope] == 'full'
  end

  protected

  def whitelisted_ips
    @whitelisted_ips ||= ENV.fetch('WHITELISTED_IPS').to_s.split(',').map(&:strip)
  end

  def require_params; end

  def switch_locale(&action)
    I18n.with_locale(current_locale, &action)
  end

  def store_current
    DotOne::Current.user = current_user
    DotOne::Current.currency = current_currency
    DotOne::Current.locale = current_locale
    DotOne::Current.time_zone = current_time_zone
  end

  def validate_origin_presence
    render json: { message: 'Invalid request host' }, status: :unauthorized if request.origin.blank?
  end

  private

  def add_sentry_user_context
    return if current_user.blank?

    Sentry.set_user(id: current_user.id, class: current_user.class.name, ip: request.remote_ip)
  end
end
