# frozen_string_literal: true

class AffiliatePaymentInfos::PropagateToPaymentJob < EntityManagementJob
  def perform(affiliate_payment_info_id)
    affiliate_payment_info = AffiliatePaymentInfo.find(affiliate_payment_info_id)

    AffiliatePayment.where(affiliate_id: affiliate_payment_info.affiliate_id).ongoing.each do |affiliate_payment|
      affiliate_payment.propagate_payment_info!
    end
  end
end
