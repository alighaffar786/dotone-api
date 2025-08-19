class Teams::CategoryParkingSerializer < ApplicationSerializer
  translatable_attributes(*Category.static_translatable_attributes)

  attributes :id, :name, :offers_count

  def offers_count
    instance_options.dig(:offers_count, object.id) || 0
  end
end
