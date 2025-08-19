module StaticTranslatable
  extend ActiveSupport::Concern

  included do
    cattr_reader :static_translatable_attributes
  end

  module ClassMethods
    ##
    # Any attribute declared on parameter
    # will have its translation pulled from translation file.
    # Example:
    # offer.cap_type will have offer.t_cap_type(locale)
    def set_static_translatable_attributes(*attrs, **prefixes)
      class_variable_set(:@@static_translatable_attributes, (static_translatable_attributes.to_a | attrs))

      attrs.flatten.each do |attribute|
        prefix = prefixes[attribute]
        prefix ||= "#{name.underscore}.#{attribute}"
        prefix = "predefined.models.#{prefix}"

        define_singleton_method "t_#{attribute}" do |value, locale = nil|
          return unless value.present?

          I18n.t("#{prefix}.#{value}", locale: locale, raise: true) rescue value
        end

        define_method "t_#{attribute}" do |locale = nil|
          return unless value = send(attribute).presence

          I18n.t("#{prefix}.#{value}", locale: locale, raise: true) rescue value
        end
      end
    end
  end
end
