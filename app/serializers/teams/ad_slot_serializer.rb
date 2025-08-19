class Teams::AdSlotSerializer < Base::AdSlotSerializer
  attributes :id, :name, :code, :dimensions, :affiliate_id, :category_group_ids

  has_many :category_groups
end
