# frozen_string_literal: true

class Creatives::SuspendExpiredJob < MaintenanceJob
  def perform
    suspend_text_creatives
    suspend_image_creatives
  end

  def suspend_text_creatives
    text_creatives = TextCreative.active.where('active_date_end < ?', Time.now)

    text_creatives.find_each do |text_creative|
      catch_exception { suspend_creative(text_creative) }
    end
  end

  def suspend_image_creatives
    ImageCreative.active.where('active_date_end < ?', Time.now).find_each do |image_creative|
      catch_exception { suspend_creative(image_creative) }
    end
  end

  def suspend_creative(creative)
    creative.assign_attributes(status: creative.class.status_suspended)
    creative.save(validate: false)
  end
end
