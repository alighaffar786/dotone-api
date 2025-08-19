class Teams::AdvertiserBalanceSerializer < Base::AdvertiserBalanceSerializer
  class NetworkSerializer < Base::NetworkSerializer
    attributes :id

    conditional_attributes :name, :sales_tax, if: :can_read_network?

    has_one :billing_currency
  end

  attributes :id, :network_id, :credit, :debit, :sales_tax, :notes, :invoice_number, :invoice_amount, :invoice_date,
    :record_type, :recorded_at, :updated_at

  original_attributes :credit, :debit, :sales_tax, :invoice_amount

  has_one :network, serializer: NetworkSerializer
end
