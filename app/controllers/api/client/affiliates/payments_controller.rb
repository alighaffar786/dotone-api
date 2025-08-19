class Api::Client::Affiliates::PaymentsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource class: 'AffiliatePayment'

  def index
    @payments = paginate(query_index)
    respond_with_pagination @payments, total_fees: query_total_fees
  end

  def recent
    respond_with @payments.latest_period.limit(5), each_serializer: Affiliates::AffiliatePayment::RecentSerializer
  end

  def redeem
    authorize! :redeem, @payment
    @payment.assign_attributes(payment_params)

    if @payment.redeem
      respond_with @payment
    else
      respond_with @payment, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = AffiliatePaymentCollection.new(@payments, params).collect.latest_period
    collection.preload(:wire_fee, :tax_fee)
  end

  def query_total_fees
    PaymentFee
      .where(affiliate_payment_id: @payments.map(&:id))
      .group(:affiliate_payment_id)
      .sum(:amount)
  end

  def payment_params
    params.require(:payment).permit(:has_invoice, :redeemed_amount)
  end
end
