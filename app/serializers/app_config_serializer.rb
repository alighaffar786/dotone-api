class AppConfigSerializer < ApplicationSerializer
  attributes :id, :profile_bg_url, :logo_url

  conditional_attributes :role, :active, if: :affiliate_user?
end
