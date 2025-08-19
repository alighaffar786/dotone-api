class AffiliateLogSerializer < ApplicationSerializer
  local_time_attributes(*AffiliateLog.local_time_attributes)

  attributes :id, :notes, :agent_id, :agent_type, :owner_id, :owner_type, :created_at

  has_one :agent, serializer: AffiliateLogAgentSerializer
end
