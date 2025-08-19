class PaymentFee < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  # Affiliate Fee Type
  # Affiliate fees have different types on different countries
  TYPES = ['Usage Fee', 'Tax', 'Wire Fees', 'Health Insurance']

  belongs_to :affiliate_payment, inverse_of: :payment_fees, touch: true

  scope :with_label, -> (*args) { where(label: args[0]) if args[0].present? }

  define_constant_methods TYPES, :label

  def self.types
    labels
  end
end
