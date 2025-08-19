class Teams::SiteInfo::MiniSerializer < ApplicationSerializer
  attributes :id, :url, :unique_visit_per_day, :description
end
