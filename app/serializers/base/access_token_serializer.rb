class Base::AccessTokenSerializer < ApplicationSerializer
  local_time_attributes(*AccessToken.local_time_attributes)
end
