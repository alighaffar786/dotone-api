class ExpertiseSerializer < ApplicationSerializer
  translatable_attributes(*Expertise.static_translatable_attributes)

  attributes :id, :name
end
