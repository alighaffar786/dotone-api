# frozen_string_literal: true

class UploadSerializer < ApplicationSerializer
  local_time_attributes(*Upload.local_time_attributes)

  attributes :id, :status, :descriptions, :uploaded_by, :error_details, :cdn_url, :file_type, :created_at
end
