module FlexibleTranslatable
  extend ActiveSupport::Concern

  include Translatable

  included do
    cattr_accessor :flexible_translatable_attribute_types
    cattr_reader :flexible_translatable_attributes

    before_save :clear_translation_on_predefined
  end

  module ClassMethods
    def set_flexible_translatable_attributes(values)
      self.flexible_translatable_attribute_types = values
      class_variable_set(:@@flexible_translatable_attributes, flexible_translatable_attributes.to_a | values.keys)

      flexible_translatable_attributes.each do |attribute|
        has_many "#{attribute}_translations".to_sym, -> { where(field: attribute) }, as: :owner, class_name: 'Translation', dependent: :destroy, autosave: true

        prefix = "predefined.models.#{name.underscore}.#{attribute}"

        define_method "t_#{attribute}_static?" do
          value = send(attribute)

          return false if value.blank?

          I18n.exists?("#{prefix}.#{value}")
        end

        define_singleton_method "t_#{attribute}" do |value, locale = nil|
          return unless value.present?

          I18n.t("#{prefix}.#{value}", locale: locale, raise: true) rescue nil
        end

        define_method "t_#{attribute}" do |locale = nil|
          locale ||= Language.current_locale
          value = send(attribute)
          key = "#{prefix}.#{value}"

          if send("t_#{attribute}_static?")
            I18n.t(key, locale: locale)
          else
            translations = send("#{attribute}_translations").index_by(&:locale)
            translations[locale.to_s]&.content.presence || value
          end
        end

        define_method "t_#{attribute}=" do |*args|
          content, locale = args.flatten
          locale ||= Language.current_locale
          translation = send("#{attribute}_translations").find_or_initialize_by(locale: locale.to_s)
          translation.update(content: content)
        end
      end
    end
  end

  def clear_translation_on_predefined
    self.class.flexible_translatable_attributes.each do |attribute|
      self.send("#{attribute}_translations=", []) if send("t_#{attribute}_static?")
    end
  end
end
