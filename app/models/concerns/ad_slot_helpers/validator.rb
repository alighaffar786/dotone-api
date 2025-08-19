module AdSlotHelpers::Validator
  class OneInventorySelectionMustExist < ActiveModel::Validator
    def validate(record)
      return unless record.category_group_ids.blank? && record.offer_ids.blank? && record.text_creative_id.blank?

      record.errors.add(:category_group_ids,
        record.errors.generate_message(:category_group_ids, :one_inventory_selection_must_exist))
    end
  end
end
