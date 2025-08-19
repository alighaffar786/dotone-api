class Teams::TraceSerializer < ApplicationSerializer
  class AgentSerializer < ApplicationSerializer
    attributes :id, :full_name
  end

  attributes :id, :created_at, :details, :agent_type, :agent

  has_one :agent_user, serializer: AgentSerializer
end
