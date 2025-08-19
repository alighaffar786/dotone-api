class Base::OrderSerializer < ApplicationSerializer
  forexable_attributes(*Order.forexable_attributes)
  local_time_attributes(*Order.local_time_attributes)
end
