class PaymentGateway < DatabaseRecords::PrimaryRecord
  include Relations::NetworkAssociated

  has_many :credit_cards, inverse_of: :payment_gateway, dependent: :nullify

  enum name: {
    stripe: 0,
    tap_pay: 1,
  }

  validates :network, :name, presence: true
  validates :network, uniqueness: { scope: :name }

  before_save :create_token, if: :stripe?

  def create_token
    customer = Stripe::Customer.create(email: network.email, name: network.name)
    self.customer_token = customer.id
  end

  def klass_name
    name.camelize
  end
end
