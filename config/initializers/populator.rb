# This module is Rails 6 adaptation to Rails 3
# populator gem to record fake data to the database
# in one go. We use populator to build development and
# staging data

# Builds multiple Populator::Record instances and saves them to the database
module Populator
  class Factory
    def rows_sql_arr
      @records.map do |record|
        quoted_attributes = record.attribute_values.map do |v|
          if v.is_a?(Hash)
            @model_class.connection.quote(v.to_yaml)
          else
            @model_class.connection.quote(v)
          end
        end
        "(#{quoted_attributes.join(', ')})"
      end
    end
  end
end
