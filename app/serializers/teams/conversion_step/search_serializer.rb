class Teams::ConversionStep::SearchSerializer < Base::ConversionStepSerializer
  attributes :id, :name, :label, :offer_id, :true_currency_id, :true_conv_type, :affiliate_conv_type

  has_many :step_prices, if: :full_scope_requested?

  has_one :true_currency
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer, if: :full_scope_requested?
end
