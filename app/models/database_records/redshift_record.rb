class DatabaseRecords::RedshiftRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :redshift, reading: :redshift }
end
