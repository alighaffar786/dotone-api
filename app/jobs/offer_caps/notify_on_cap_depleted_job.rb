# frozen_string_literal: true

class OfferCaps::NotifyOnCapDepletedJob < NotificationJob
  def perform(entity_id:, entity_type:, cap_instance:)
    @entity = entity_type.constantize.find(entity_id)

    @entity.notify_on_cap_depleted!(
      cap_instance,
      OfferCap::STAGE_1_DEPLETING_RATIO,
      OfferCap::STAGE_2_DEPLETING_RATIO,
    )
  end
end
