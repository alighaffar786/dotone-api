class DownloadSerializer < ApplicationSerializer
  local_time_attributes(*Download.local_time_attributes)

  attributes :id, :status, :name, :notes, :downloaded_by, :cdn_url, :created_at
end
