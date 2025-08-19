class Base::AdvertiserBalanceSerializer < ApplicationSerializer
  local_time_attributes(*AdvertiserBalance.local_time_attributes)
  forexable_attributes(*AdvertiserBalance.forexable_attributes)
end
