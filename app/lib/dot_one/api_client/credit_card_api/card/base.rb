module DotOne::ApiClient::CreditCardApi::Card
  class Base
    DEFAULT_MERCHANT = 'UpstartDNA_GP_USD_Only'.freeze
    DEFAULT_CURRENCY = 'USD'.freeze
    CARD_TYPES = {
      -1 => 'Unknown',
      1 => 'VISA',
      2 => 'MasterCard',
      3 => 'JCB',
      4 => 'Union Pay',
      5 => 'AMEX',
    }.freeze

    attr_accessor :credit_card, :network, :payment_gateway

    def initialize(credit_card)
      @credit_card = credit_card
      @network = credit_card.network
      @payment_gateway = credit_card.payment_gateway
    end

    def assign_attributes
      raise NotImplementedError
    end

    def unlink
      raise NotImplementedError
    end

    def default!
      raise NotImplementedError
    end

    def currency_code
      network.currency&.code || DEFAULT_CURRENCY
    end

    def raise_invalid_card
      credit_card.errors.add(:base, 'Unexpected error while saving the card')
      credit_card.send(:throw, :abort)
    end
  end
end
