class DatabaseRecords::PrimaryRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :primary, reading: :primary }

  MAX_TEXT_DATA_TYPE_LENGTH = 64.kilobytes - 1
end
