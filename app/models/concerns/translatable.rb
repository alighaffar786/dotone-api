module Translatable
  extend ActiveSupport::Concern

  included do
    has_many :translations, as: :owner, inverse_of: :owner, dependent: :destroy, autosave: true

    accepts_nested_attributes_for :translations, reject_if: -> (attrs) { attrs['id'].blank? && Translation.sanitize(attrs['content']).blank? }

    scope :preload_translations, -> (*fields) {
      relations = fields.map { |field| "#{field}_translations".to_sym }
      preload(*relations)
    }

    before_validation :clear_translations
  end

  private

  def clear_translations
    translations.each do |translation|
      translation.mark_for_destruction if translation.content.blank?
    end

    t_attributes = []
    t_attributes.concat(self.class.dynamic_translatable_attributes) if self.class.respond_to?(:dynamic_translatable_attributes)
    t_attributes.concat(self.class.flexible_translatable_attributes) if self.class.respond_to?(:flexible_translatable_attributes)

    t_attributes.each do |attr|
      next unless (respond_to?(:aff_hash) && predefined_flag?(attr.to_s.sub('flag_','')) && send(attr).blank?) ||
        (send(attr).blank? && respond_to?("#{attr}_changed?") && send("#{attr}_changed?"))

      send("#{attr}_translations").each(&:mark_for_destruction)
    end
  end
end
