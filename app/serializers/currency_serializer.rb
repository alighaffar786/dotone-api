# frozen_string_literal: true

class CurrencySerializer < ApplicationSerializer
  translatable_attributes(*Currency.static_translatable_attributes)

  attributes :id, :name, :code, :symbol, :platform?

  def name
    code_name
  end
end
