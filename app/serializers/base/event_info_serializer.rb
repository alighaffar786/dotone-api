class Base::EventInfoSerializer < ApplicationSerializer
  forexable_attributes(*EventInfo.forexable_attributes)
  local_time_attributes(*EventInfo.local_time_attributes)
  translatable_attributes(*EventInfo.dynamic_translatable_attributes)
end
