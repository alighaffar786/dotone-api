# frozen_string_literal: true

class AffiliatePayments::BulkUpdateJob < EntityManagementJob
  def perform(ids, params = {})
    update_params = params.compact_blank

    payments = AffiliatePayment.where(id: ids)

    payments.find_each do |payment|
      catch_exception { payment.update!(update_params) }
    end
  end
end
