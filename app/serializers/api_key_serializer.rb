class ApiKeySerializer < ApplicationSerializer
  local_time_attributes(*ApiKey.local_time_attributes)

  attributes :id, :created_at, :value, :last_used_at, :status, :owner_id, :owner_type
end
