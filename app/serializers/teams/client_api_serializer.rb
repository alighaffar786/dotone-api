# frozen_string_literal: true

class Teams::ClientApiSerializer < Base::ClientApiSerializer
  attributes :id, :name, :key, :host, :path, :api_type, :column_settings, :auth_token, :username,
    :password, :status, :api_affiliate_id, :owner_type, :owner_id, :imported_at, :request_body_content

  has_one :owner
end
