# frozen_string_literal: true

class TextCreatives::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params: {})
    ability = Ability.new(user)
    text_creatives = TextCreative.accessible_by(ability, :update).where(id: ids)

    text_creatives.find_each do |text_creative|
      catch_exception { text_creative.update!(params) }
    end
  end
end
