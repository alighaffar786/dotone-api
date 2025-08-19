class Base::AdSlotSerializer < ApplicationSerializer
  local_time_attributes(*AdSlot.local_time_attributes)
end
