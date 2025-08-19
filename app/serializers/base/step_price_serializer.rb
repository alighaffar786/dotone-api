class Base::StepPriceSerializer < ApplicationSerializer
  forexable_attributes(*StepPrice.forexable_attributes)
end
