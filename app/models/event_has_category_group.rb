class EventHasCategoryGroup < DatabaseRecords::PrimaryRecord
  belongs_to :category_group, inverse_of: :event_has_category_groups
  belongs_to :event_info, inverse_of: :event_has_category_groups
end
