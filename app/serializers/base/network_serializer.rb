class Base::NetworkSerializer < ApplicationSerializer
  local_time_attributes(*Network.local_time_attributes)
  forexable_attributes(*Network.forexable_attributes)

  user_config_attributes

  attribute :name, if: :can_read_network?
end
