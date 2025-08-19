module Relations::CurrencyAssociated
  extend ActiveSupport::Concern

  included do
    belongs_to :currency, inverse_of: self.name.tableize
  end

  def default_currency
    @default_currency ||= currency || Currency.platform
  end

  def currency_code
    default_currency.code
  end

  def currency_rate
    Currency.rate(currency_code, Currency.platform.code)
  end

  def currency_code=(value)
    self.currency_id = Currency.cached_find_by(code: value)&.id
  end

  def cached_currency
    Currency.cached_find(currency_id)
  end
end
