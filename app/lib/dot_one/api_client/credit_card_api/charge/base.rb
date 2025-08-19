module DotOne::ApiClient::CreditCardApi::Charge
  class Base
    attr_accessor :charge, :network

    def initialize(charge)
      @charge = charge
      @network = charge.network
    end

    def assign_attributes
      raise NotImplementedError
    end

    def error_to_charge
      charge.errors.add(:base, 'Unexpected error while charge the card')
      charge.send(:throw, :abort)
    end
  end
end
