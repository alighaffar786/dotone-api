# Any class that includes this
# will need to define the attribute
# that requires masking.
# This module provides several ways to mask
# the value depending on the value type.

module AddressMaskable
  extend ActiveSupport::Concern

  included do
    cattr_reader :maskable_address_attributes
  end

  module ClassMethods
    # To mask an ip address value type
    def set_maskable_address_attributes(*attrs)
      class_variable_set(:@@maskable_address_attributes, attrs)

      attrs.flatten.each do |attribute|
        define_method "masked_#{attribute}".to_sym do
          value = send(attribute)
          return if value.blank?

          array_value = value.split('.')
          first_digit = array_value.first
          last_digit = array_value.last
          "#{first_digit}.*.*.#{last_digit}"
        end
      end
    end
  end
end
