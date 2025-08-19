class Base::AffiliateApplicationSerializer < ApplicationSerializer
  local_time_attributes(*AffiliateApplication.local_time_attributes)
end
