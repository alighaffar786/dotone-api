class Base::TermSerializer < ApplicationSerializer
  translatable_attributes(*Term.dynamic_translatable_attributes)
end
