module Maskable
  extend ActiveSupport::Concern

  included do
    cattr_reader :maskable_attributes
  end

  module ClassMethods
    def set_maskable_attributes(*attrs, **mask_lengths)
      class_variable_set(:@@maskable_attributes, (maskable_attributes.to_a | attrs))

      attrs.flatten.each do |attribute|
        define_method "masked_#{attribute}" do
          value = send(attribute).to_s
          return if value.blank?

          mask_length = [mask_lengths[attribute.to_sym] || 4, value.length].min

          ('*' * [0, value.length - mask_length].max) + value[-mask_length..-1]
        end

        define_method "masked_#{attribute}=" do |value|
          return if value.to_s.include?('*')

          send("#{attribute}=", value)
        end

        define_method "#{attribute}=" do |value|
          return if value.to_s.include?('*')

          super(value)
        end
      end
    end
  end
end
