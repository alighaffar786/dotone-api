class Affiliates::AdSlotSerializer < Base::AdSlotSerializer
  attributes :id, :text_creative_id, :name, :code, :dimensions, :inventory_type, :offer_ids, :category_group_ids,
    :created_at

  has_many :offers, serializer: Affiliates::NetworkOffer::MiniSerializer
  has_many :category_groups

  has_one :text_creative
end
