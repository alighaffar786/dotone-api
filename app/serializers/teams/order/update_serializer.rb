class Teams::Order::UpdateSerializer < Teams::OrderSerializer
  has_one :copy_stat, serializer: Teams::AffiliateStatSerializer
end
