class Teams::JobStatusCheckSerializer < ApplicationSerializer
  attributes :id, :created_at, :status, :request_data
end
