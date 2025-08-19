# frozen_string_literal: true

class Stripe::NetworkPaymentJob < ApplicationJob
  queue_as :default

  def perform
    start_date = 1.month.ago.getlocal(TimeZone.platform.gmt_string).beginning_of_day.to_i
    end_date = 1.month.ago.getlocal(TimeZone.platform.gmt_string).end_of_day.to_i
    networks = Network.includes(:payment_gateway).where.not(payment_gateway: { customer: nil })

    networks.each do |network|
      charges = Stripe::Charge.search(
        query: "customer:#{network.payment_gateway.customer_id} AND created<=#{start_date} AND created>=#{end_date} AND status:'succeeded'",
      )

      next if charges.data.empty?

      # TODO: amount to be calculated
      amount = 100
      ::Charge.create(
        amount: amount,
        network: network,
      )
    end
  end
end
