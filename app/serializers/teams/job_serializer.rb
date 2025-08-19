class Teams::JobSerializer < ApplicationSerializer
  attributes :id, :created_at, :job_type, :queue, :owner_type, :owner_id, :attempts, :handler, :last_error, :run_at
end
