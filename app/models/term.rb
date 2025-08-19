class Term < DatabaseRecords::PrimaryRecord
  include DynamicTranslatable

  has_and_belongs_to_many :event_offers, -> { where(type: 'EventOffer') },
    class_name: 'Offer', join_table: :offer_terms, inverse_of: :terms

  validates :text, presence: true

  set_dynamic_translatable_attributes(text: :plain)

  scope :like, -> (*args) { where('text LIKE ?', "%#{args[0]}%") if args[0].present? }
end
