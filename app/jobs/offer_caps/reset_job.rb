# frozen_string_literal: true

class OfferCaps::ResetJob < MaintenanceJob
  def perform(klass, id, _run_time)
    @object = klass.constantize.find(id)
    @object.reset_cap!
  end
end
