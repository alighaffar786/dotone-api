module DotOne::I18n
  extend ActiveSupport::Concern
  extend self

  def t(key, **options)
    ::I18n.t(key, **options)
  end

  def st(key, **options)
    ::I18n.t("shared.#{key}", **options)
  end

  def st_time(key, count, **options)
    ::I18n.t(key.to_sym, count: count, **options)
  end

  def predefined_t(str, **options)
    ::I18n.t("predefined.models.#{str}", raise: true, **options)
  end

  ##
  # Method to access global texts translation
  def tt(key, **options)
    return if key.blank?

    ::I18n.t("texts.#{key}", raise: true, **options)
  end

  def download_t(key, **options)
    ::I18n.t("download_columns.models.#{key}", raise: true, **options)
  end

  # Method to print out error message from
  # translation files specific for Error class
  def err(key, **options)
    ::I18n.t("errors.#{key}", **options)
  end

  module ClassMethods
    include DotOne::I18n
  end
end
