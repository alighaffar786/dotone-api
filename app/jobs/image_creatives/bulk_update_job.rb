# frozen_string_literal: true

class ImageCreatives::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params: {})
    ability = Ability.new(user)
    image_creatives = ImageCreative.accessible_by(ability, :update).where(id: ids)

    updated = []

    image_creatives.find_each do |image_creative|
      catch_exception do
        if image_creative.update!(params) && image_creative.rejected? && image_creative.status_previously_changed?
          updated.push(image_creative)
        end
      end
    end

    if updated.present?
      ImageCreative.send_rejected_notification(updated)
    end
  end
end
