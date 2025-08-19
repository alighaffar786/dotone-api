class Translation < DatabaseRecords::PrimaryRecord
  include Owned

  belongs_to_owner autosave: true

  validates :owner_id, :owner_type, :locale, :content, presence: true
  validates :field, presence: true, uniqueness: { scope: [:owner_type, :owner_id, :locale] }

  def self.sanitize(value)
    Sanitize.fragment(value.to_s.gsub('&nbsp;', '')).gsub(/\s*/, '')
  end

  def editor_style
    @editor_style ||= owner.dynamic_translatable_attribute_types&.dig(field.to_sym)
  end

  def default_content
    @value_content ||= owner.send(field)
  end
end
