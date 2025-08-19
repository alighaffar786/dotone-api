class EmailOptIn < DatabaseRecords::PrimaryRecord
  include Owned

  belongs_to :email_template, inverse_of: :email_opt_ins
end
