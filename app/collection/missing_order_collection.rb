class MissingOrderCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present? || params[:rejecters].present?
    filter_by_affiliates if params[:affiliate_ids].present?
    filter_by_network_offers if params[:offer_ids].present?
    filter_by_affiliate_users if params[:affiliate_user_ids].present?
    filter_by_question_types if params[:question_types].present?
    filter_by_payment_methods if params[:payment_methods].present?
    filter_by_devices if params[:devices].present?
    filter_by_order_numbers if params[:order_numbers].present?
    filter_distinct
  end

  def filter_by_statuses
    filter do
      @relation.with_statuses(param_statuses)
    end
  end

  def filter_by_affiliates
    filter { @relation.with_affiliates(params[:affiliate_ids]) }
  end

  def filter_by_network_offers
    filter { @relation.with_offers(params[:offer_ids]) }
  end

  def filter_by_affiliate_users
    filter do
      @relation
        .left_joins(:affiliate_users)
        .where(affiliate_users: { id: params[:affiliate_user_ids] })
    end
  end

  def filter_by_question_types
    filter { @relation.where(question_type: params[:question_types]) }
  end

  def filter_by_payment_methods
    filter { @relation.where(payment_method: params[:payment_methods]) }
  end

  def filter_by_devices
    filter { @relation.where(device: params[:devices]) }
  end

  def filter_by_order_numbers
    filter { @relation.where(order_number: params[:order_numbers]) }
  end

  def default_sorted
    sort do
      @relation.sort_by_status.order(created_at: :desc)
    end
  end

  def filter_by_search
    filter do
      @relation
        .left_joins(:offer)
        .where('offer_id LIKE :q OR affiliate_id LIKE :q OR offers.name LIKE :q OR order_number LIKE :q OR missing_orders.id LIKE :q', q: "%#{params[:search]}%")
    end
  end

  def param_statuses
    statuses = [params[:statuses]].flatten.compact

    if statuses.include?(MissingOrder.status_rejected) && (network? || affiliate? || (affiliate_user? && params[:rejecters].blank?))
      statuses = statuses | MissingOrder.status_considered_rejected
    elsif affiliate_user? && params[:rejecters].present?
      rejected_statuses = [params[:rejecters]].flatten.map { |rejecter| MissingOrder.rejecters[rejecter.to_sym] }.compact
      statuses = (statuses - MissingOrder.status_considered_rejected) | rejected_statuses
    end

    statuses
  end
end
