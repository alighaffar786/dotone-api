module DotOne::Errors
  class AffiliateStatNotFoundError < StandardError
    attr_reader :click_id, :order_number

    def initialize(click_id, order_number, message)
      @click_id = click_id
      @order_number = order_number
      super(message)
    end
  end
end
