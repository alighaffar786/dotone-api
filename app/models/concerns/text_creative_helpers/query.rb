module TextCreativeHelpers::Query
  extend ActiveSupport::Concern
  include HasAffiliateOffers

  module ClassMethods
    def select_approval_status(affiliate)
      super(affiliate, :reapply_note, :status_summary, { status_reason: :reject_reason }, relation: joins(:offer))
    end

    def agg_affiliate_pay(user, currency_code)
      super(user, currency_code, relation: joins(:offer))
    end

    def with_approval_statuses(user, *approval_statuses)
      super(user, *approval_statuses, relation: joins(:offer))
    end
  end
end
