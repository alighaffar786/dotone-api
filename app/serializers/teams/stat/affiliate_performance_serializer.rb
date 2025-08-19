class Teams::Stat::AffiliatePerformanceSerializer < ApplicationSerializer
  attributes :clicks, :captured, :affiliate_id

  has_many :affiliate, serializer: Teams::Affiliate::MiniSerializer
end
