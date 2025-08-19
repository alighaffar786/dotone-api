class Base::ProductSerializer < ApplicationSerializer
  forexable_attributes(:price, :retail_price, :sale_price)
  local_time_attributes(*Product.local_time_attributes)

  def image
    object.images&.first
  end
end
