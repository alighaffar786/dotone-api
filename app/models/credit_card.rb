class CreditCard < DatabaseRecords::PrimaryRecord
  attr_accessor :exp_month, :exp_year, :token

  belongs_to :payment_gateway, optional: false, inverse_of: :credit_cards

  has_many :charges, inverse_of: :credit_card, dependent: :nullify

  has_one :network, through: :payment_gateway

  validates :unique_identifier, uniqueness: { scope: :payment_gateway_id }
  validates :exp_month, :exp_year, :card_token, :unique_identifier, :last_4_digits, :brand, presence: true
  validates :card_key, presence: true, if: :payment_gateway_tap_pay?
  validates :token, presence: true

  before_validation :ensure_has_payment_gateway!
  before_validation :api_client_assign_attributes, on: :create, if: :token?
  before_create :set_default
  before_create :set_expiry_date
  before_destroy :ensure_not_default
  after_destroy :api_client_unlink

  delegate :name, :stripe?, :tap_pay?, to: :payment_gateway, prefix: true
  delegate :unlink, :default!, :assign_attributes, to: :api_client, prefix: true, allow_nil: true

  scope :default, -> { where(default: true) }

  def default!
    network.credit_cards.update_all(default: false)
    update_column(:default, true)

    api_client_default!
  end

  private

  def api_client
    @api_client ||= begin
      klass = "DotOne::ApiClient::CreditCardApi::Card::#{payment_gateway.klass_name}".constantize
      klass.new(self)
    end
  end

  def set_expiry_date
    self.expire_at = Date.new(exp_year.to_i, exp_month.to_i).end_of_month
  end

  def set_default
    self.default = payment_gateway.credit_cards.empty?
  end

  def ensure_not_default
    return unless default?

    errors.add(:default, 'not able to delete')
    throw :abort
  end

  def ensure_has_payment_gateway!
    return unless network

    self.payment_gateway = network.payment_gateways.where(name: network.payment_gateway_type).first_or_create
  end
end
