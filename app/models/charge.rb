class Charge < DatabaseRecords::PrimaryRecord
  include Relations::NetworkAssociated

  MINIMUM_CHARGE = 101 # USD 1.01

  belongs_to :credit_card, optional: false, inverse_of: :charges
  has_one :payment_gateway, through: :credit_card

  validates :amount, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: MINIMUM_CHARGE, only_integer: true }
  validate :owner_of_credit_card

  before_validation :ensure_has_payment_gateway!
  before_validation :ensure_has_credit_card!
  before_validation :set_default_currency_code
  before_create :api_client_assign_attributes

  delegate :payment_gateway_type, to: :network
  delegate :assign_attributes, to: :api_client, prefix: true, allow_nil: true

  enum status: {
    success: 'success',
  }

  private

  def set_default_currency_code
    self.currency_code ||= network.currency&.code || CreditCard::DEFAULT_CURRENCY
  end

  def owner_of_credit_card
    return if payment_gateway&.credit_cards&.exists?(id: credit_card_id)

    errors.add(:credit_card, 'invalid card')
  end

  def ensure_has_credit_card!
    self.credit_card_id ||= payment_gateway.credit_cards.default&.first&.id
  end

  def ensure_has_payment_gateway!
    return unless network

    self.payment_gateway = network.payment_gateways.where(name: payment_gateway_type).first_or_create
  end

  def api_client
    @api_client ||= begin
      klass = "DotOne::ApiClient::CreditCardApi::Charge::#{payment_gateway.klass_name}".constantize
      klass.new(self)
    end
  end
end
