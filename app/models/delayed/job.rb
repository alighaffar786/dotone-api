class Delayed::Job < DatabaseRecords::SecondaryRecord
  self.table_name = 'delayed_jobs'

  belongs_to :owner, polymorphic: true
end
