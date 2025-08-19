class Base::OfferVariantSerializer < ApplicationSerializer
  translatable_attributes(*OfferVariant.dynamic_translatable_attributes)
end
