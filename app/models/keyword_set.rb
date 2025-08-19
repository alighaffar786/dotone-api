class KeywordSet < DatabaseRecords::PrimaryRecord
  belongs_to :owner, polymorphic: true, inverse_of: :keyword_set, touch: true
end
