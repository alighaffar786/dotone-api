class Teams::ClickAbuseReportSerializer < ApplicationSerializer
  attributes :id, :token, :affiliate_id, :offer_variant_id, :user_agent, :ip_address, :raw_request, :referer, :error_details, :count,
    :updated_at
end
