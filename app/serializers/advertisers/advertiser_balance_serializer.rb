class Advertisers::AdvertiserBalanceSerializer < Base::AdvertiserBalanceSerializer
  attributes :id, :credit, :debit, :sales_tax, :recorded_at, :record_type
end
