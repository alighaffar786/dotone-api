class Track::BaseController < ActionController::Base
  include BooleanHelper
  include CacheHandler
  include Track::CookieHandler
  include Track::CurrentHandler
  include Track::ExceptionHandler
  include Track::ValidateHelper

  layout 'track'

  before_action :store_current, :check_device_info
  around_action :switch_locale

  protected

  def current_user; end

  def switch_locale(&action)
    I18n.with_locale(current_locale, &action)
  end

  def store_current
    DotOne::Current.user = current_user
    DotOne::Current.currency = current_currency
    DotOne::Current.locale = current_locale
    DotOne::Current.time_zone = current_time_zone
  end

  def whitelisted_ips
    @whitelisted_ips ||= ENV.fetch('WHITELISTED_IPS').to_s.split(',').map(&:strip)
  end

  ##
  # Helper to use data from params to replace
  # any token in arg.
  # This is useful to carry forward any data from source URL
  # parameters to its target redirect URL.
  # Deeplinking is one feature that will use this as
  # the final deep link URL is contained within the
  # original Tracking URL.
  def interpolate_from_params(arg, data = {})
    return if arg.blank?

    data = data.to_h.with_indifferent_access
    arg.gsub(TOKEN_REGEX) do |_x|
      raw_key = ::Regexp.last_match(1)

      decoded_requested = raw_key.match(/_decoded$/i).present?
      double_encoded_requested = raw_key.match(/_double_encoded$/i).present?

      sanitized_key = raw_key.gsub(/(_decoded|_double_encoded)$/i, '')

      if data.keys.include?(sanitized_key) && data[sanitized_key].present?
        if decoded_requested
          data[sanitized_key]
        elsif double_encoded_requested
          CGI.escape(CGI.escape(data[sanitized_key]))
        else
          CGI.escape(data[sanitized_key])
        end
      elsif params[sanitized_key].present?
        params[sanitized_key]
      else
        "-#{raw_key}-"
      end
    end.html_safe
  end

  def respond_with(resource, **args)
    status = args.delete(:status) || :ok

    respond_to do |format|
      format.json { render(json: resource, status: status, **args) }
      format.html { block_given? ? yield(resource, status, **args) : nil }
    end
  end

  def check_device_info
    current_device_info.to_data_for_tracking
  rescue Exception => e
    Sentry.capture_exception(e)
  end
end
