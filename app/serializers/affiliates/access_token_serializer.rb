class Affiliates::AccessTokenSerializer < Base::AccessTokenSerializer
  attributes :id, :created_at, :value, :partner_app_name, :last_used_at, :status
end
