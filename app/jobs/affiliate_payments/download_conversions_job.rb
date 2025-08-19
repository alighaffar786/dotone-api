# frozen_string_literal: true

class AffiliatePayments::DownloadConversionsJob < ApplicationJob
  queue_as :download_csv

  def perform(id)
    @affiliate_payment = AffiliatePayment.find(id)
    @affiliate_payment.download_conversions!
  end
end
