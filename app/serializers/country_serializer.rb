class CountrySerializer < ApplicationSerializer
  translatable_attributes(*Country.static_translatable_attributes)
  attributes :id, :code, :continent, :iso_3_country_code, :name, :continent_code
end
