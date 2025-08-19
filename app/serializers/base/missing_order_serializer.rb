class Base::MissingOrderSerializer < ApplicationSerializer
  forexable_attributes(*MissingOrder.forexable_attributes)
  local_time_attributes(*MissingOrder.local_time_attributes)

  def status
    if object.considered_rejected?
      MissingOrder.status_rejected
    else
      object.status
    end
  end
end
