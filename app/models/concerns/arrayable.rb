module Arrayable
  extend ActiveSupport::Concern

  included do
    cattr_reader :array_attributes
  end

  module ClassMethods
    def set_array_attributes(*attrs)
      class_variable_set(:@@array_attributes, (array_attributes.to_a | attrs))

      attrs.flatten.each do |attribute|
        define_method "#{attribute}_array" do
          send(attribute).to_s.split(/\s+|\n+|\,\s*/).reject(&:blank?)
        end
      end
    end
  end
end
