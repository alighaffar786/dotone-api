class Base::AffiliateFeedSerializer < ApplicationSerializer
  local_time_attributes(*AffiliateFeed.local_time_attributes)
  translatable_attributes(*AffiliateFeed.dynamic_translatable_attributes)
end
