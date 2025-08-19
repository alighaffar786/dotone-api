class Base::ConversionStepSerializer < ApplicationSerializer
  forexable_attributes(*ConversionStep.forexable_attributes)
  translatable_attributes(*ConversionStep.flexible_translatable_attributes)

  def original_true_pay
    object.true_pay
  end

  def original_affiliate_pay
    object.affiliate_pay
  end
end
