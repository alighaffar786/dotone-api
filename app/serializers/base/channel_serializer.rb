class Base::ChannelSerializer < ApplicationSerializer
  local_time_attributes(*Channel.local_time_attributes)
end
