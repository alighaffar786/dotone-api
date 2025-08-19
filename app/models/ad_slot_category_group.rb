class AdSlotCategoryGroup < DatabaseRecords::PrimaryRecord
  belongs_to :ad_slot, inverse_of: :ad_slot_category_groups
  belongs_to :category_group, inverse_of: :ad_slot_category_groups
end
