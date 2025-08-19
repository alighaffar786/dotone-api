module Relations::LanguageAssociated
  extend ActiveSupport::Concern

  included do
    belongs_to :language, inverse_of: self.name.tableize

    validates :language_id, presence: true, if: :new_record?

    before_validation :set_default_language

    scope :with_locales, -> (*args) {
      includes(:language).where(languages: { code: args.flatten }) if args[0].present?
    }
  end

  def default_language
    @default_language ||= language || Language.platform
  end

  def locale
    default_language.code
  end

  def locale=(value)
    self.language_id = Language.cached_find_by(code: value)&.id
  end

  def cached_language
    Language.cached_find(language_id)
  end

  private

  def set_default_language
    self.language_id ||= Language.platform.id
  end
end
