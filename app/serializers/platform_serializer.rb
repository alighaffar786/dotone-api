class PlatformSerializer < ApplicationSerializer
  translatable_attributes(*WlCompany.dynamic_translatable_attributes)

  attributes :id, :affiliate_terms
end
