module ExceptionHelper
  extend self

  def catch_exception
    yield if block_given?
  rescue Exception => e
    if Rails.env.production?
      Sentry.capture_exception(e)
    else
      raise e
    end
  end
end
