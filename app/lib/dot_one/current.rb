class DotOne::Current
  class << self
    def currency
      RequestLocals.fetch(:current_currency) { Currency.platform }
    end

    def currency=(currency)
      RequestLocals.store[:current_currency] = currency
    end

    def locale
      RequestLocals.fetch(:current_locale) { I18n.locale.to_s }
    end

    def locale=(locale)
      RequestLocals.store[:current_locale] = locale
    end

    def time_zone
      RequestStore.fetch(:current_time_zone) { TimeZone.platform }
    end

    def time_zone=(time_zone)
      RequestStore.store[:current_time_zone] = time_zone
    end

    def user
      RequestLocals.fetch(:current_user) { nil }
    end

    def user=(user)
      RequestLocals.store[:current_user] = user
    end
  end
end
